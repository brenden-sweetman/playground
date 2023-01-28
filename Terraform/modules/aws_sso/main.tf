data "aws_ssoadmin_instances" "default" {}

data "aws_organizations_organization" "default" {}

locals {
  # Create Permission Set locals
  # organizational_units = {
  #   for name, config in var.permission_sets : name =>
  #   coalesce(config.ous, [])
  # }
  account_ids = {
    for name, config in var.permission_sets : name =>
    coalesce(config.account_ids, [])
  }
  sso_groups = {
    for name, config in var.permission_sets : name =>
    coalesce(config.sso_groups, [])
  }
  all_sso_groups = distinct(flatten([
    for name, sso_groups in local.sso_groups : sso_groups 
  ]))
  inline_policy_statements = {
    for name, config in var.permission_sets : name =>
    coalesce(config.inline_policy_statements, [])
  }
  customer_managed_policies = {
    for name, config in var.permission_sets : name =>
    coalesce(config.customer_managed_policies, [])
  }
  aws_managed_policies = {
    for name, config in var.permission_sets : name =>
    coalesce(config.aws_managed_policies, [])
  }
  customer_managed_permissions_boundary = {
    for name, config in var.permission_sets : name =>
    coalesce(config.customer_managed_permissions_boundary, {})
  }
  aws_managed_permissions_boundary = {
    for name, config in var.permission_sets : name =>
    lookup(config, "aws_managed_permissions_boundary", null)
   }
}

# Create permission set
resource "aws_ssoadmin_permission_set" "default" {
  for_each         = var.permission_sets
  name             = lookup(each.value, "name", each.key)
  description      = lookup(each.value, "description", "Managed by Terraform")
  instance_arn     = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  relay_state      = lookup(each.value, "relay_state", null)
  session_duration = lookup(each.value, "session_duration", "PT8H")

  tags = merge(
    var.tags,
    {
      Name = lookup(each.value, "name", each.key)
    }
  )

}

# Build/Attach Inline Policies:
resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  for_each           = { for k, v in local.inline_policy_statements : k => v if length(v) > 0 }
  inline_policy      = data.aws_iam_policy_document.default[each.key].json
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn

}

data "aws_iam_policy_document" "default" {
  for_each = { for k, v in local.inline_policy_statements : k => v if length(v) > 0 }
  dynamic "statement" {
    for_each = [ for v in coalesce(each.value, []) : v ] 
    content {
      sid           = statement.value.sid
      effect        = statement.value.effect
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)
      dynamic "condition" {
        for_each = [ for v in coalesce(statement.value.conditions, []) : v ]
        content {
          test     = lookup(condition.value, "test", null)
          variable = lookup(condition.value, "variable", null)
          values   = lookup(condition.value, "values", null)
        }
      }
    }
  }
}

# Attach Managed Policies
resource "aws_ssoadmin_customer_managed_policy_attachment" "default" {
  for_each = merge([
    for k, v in local.customer_managed_policies : {
      for customer_policy in v : "${k}/${customer_policy.name}" => {
        customer_policy_name = lookup(customer_policy, "name")
        customer_policy_path = lookup(customer_policy, "path", null)
        name                 = k
    } if length(v) > 0 }
  ]...)
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
  customer_managed_policy_reference {
    name = lookup(each.value, "customer_policy_name")
    path = lookup(each.value, "customer_policy_path")
  }
}
resource "aws_ssoadmin_managed_policy_attachment" "default" {
  for_each = merge([for k, v in local.aws_managed_policies : {
    for arn in v : "${k}/${arn}" => {
      name = k
      arn  = arn
    } if length(v) > 0 }
  ]...)
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
  managed_policy_arn = lookup(each.value, "arn")
}

# Attach Permissions Boundaries
# Attach customer managed permissions boundaries
resource "aws_ssoadmin_permissions_boundary_attachment" "default_customer" {
  for_each = { for k, v in local.customer_managed_permissions_boundary : k => v if length(v) > 0}
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn
  permissions_boundary {
    customer_managed_policy_reference {
      name = lookup(each.value, "name", null)
      path = lookup(each.value, "path", null)
    }
  }
}
# Attach aws managed permissions boundaries
resource "aws_ssoadmin_permissions_boundary_attachment" "default_aws" {
  for_each = { for k, v in local.aws_managed_permissions_boundary: k=>v if v != null}
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn
  permissions_boundary {
    managed_policy_arn = each.value
  }
}


# Get SSO groups for each permission set
data "aws_identitystore_group" "default" {
  for_each = toset([ for sso_group in local.all_sso_groups: sso_group if sso_group != null ])
  identity_store_id       = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0] 
  alternate_identifier {
    unique_attribute {
      attribute_path = "DisplayName"
      attribute_value = each.key
    }
  }
}


# Attach permission set to accounts
resource "aws_ssoadmin_account_assignment" "default" {
  for_each = merge([for k, v in local.account_ids : merge([
    for account_id in v : {
      for sso_group in local.sso_groups[k] : "${k}/${account_id}/${sso_group}" => {
        name = k
        account_id = account_id
        sso_group= sso_group 
      } if length(local.sso_groups) > 0 
    }]...)
  ]...)
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[each.value.name].arn 
  principal_id = data.aws_identitystore_group.default[each.value.sso_group].group_id
  principal_type = "GROUP"
  target_id = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
