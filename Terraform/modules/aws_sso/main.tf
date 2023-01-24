data "aws_ssoadmin_instances" "default" {}

locals {
    inline_policies = {
        for name, config in var.permission_sets : name =>
            lookup(config, "inline_policies", {})
    }
    customer_managed_policies = {
        for name, config in var.permission_sets : name =>
            lookup(config, "customer_managed_policies", {})
    }
    aws_managed_policies = {
        for name, config in var.permission_sets : name =>
            lookup(config, "aws_managed_policies", {})
    }
    permissions_boundaries = {
        for name, config in var.permission_sets : name =>
            lookup(config, "permissions_boundaries", {})
    }
    customer_managed_permissions_boundaries = {
        for name, boundary in local.permissions_boundaries : name =>
            boundary if lookup(boundary, "customer_managed_policy_reference", null) != null
    }
    aws_managed_permissions_boundaries = {
        for name, boundary in local.permissions_boundaries : name =>
            boundary if lookup(boundary, "managed_policy_arn", null) != null

    }
}

# Create permission set
resource "aws_ssoadmin_permission_set" "default" {
    for_each = var.permission_sets
    name = lookup(each.value, "name", each.key)
    description = lookup(each.value, "description", "Managed by Terraform")
    instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
    relay_state = lookup(each.value, "relay_state", null)
    session_duration = lookup(each.value, "session_duration", "PT8H")

    tags = merge (
        var.tags,
        {
            Name = lookup(each.value, "name", each.key)
        }
    )

}

# Build/Attach Inline Policies:
resource "aws_ssoadmin_permission_set_inline_policy" "default" {
  for_each = { for k, v in local.inline_policies : k => v if length(v) > 0 }
  inline_policy      = data.aws_iam_policy_document.default[each.key].json
  instance_arn       = tolist(data.aws_ssoadmin_instances.default.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.default[each.key].arn

}

data "aws_iam_policy_document" "default" {
  for_each = { for k, v in local.inline_policies : k => v if length(v) > 0 }
  dynamic "statement" {
    for_each = each.value
    content {
      sid           = statement.value.sid
      effect        = statement.value.effect
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)
      dynamic "condition" {
        for_each = lookup(statement.value, "conditions", [])
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
                name = k
            } if length(v) > 0 }
    ] ...)
    instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
    permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
    customer_managed_policy_reference {
      name = lookup(each.value, "customer_policy_name")
      path = lookup(each.value, "customer_policy_path")
    }
}
resource "aws_ssoadmin_managed_policy_attachment" "default" {
    for_each = merge([for k, v in local.aws_managed_policies : {
        for arn in v: "${k}/${arn}" => {
            name = k
            arn = arn
        } if length(v) > 0 }
    ] ...)
    instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
    permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
    managed_policy_arn = lookup(each.value, "arn")
}

# Attach Permissions Boundaries
# Attach customer managed permissions boundaries
resource "aws_ssoadmin_permissions_boundary_attachment" "default_customer" {
    for_each = merge([for k, v in local.customer_managed_permissions_boundaries:{
        for customer_policy in v : "${k}/${customer_policy.name}" => {
            customer_policy_name = lookup(customer_policy, "name")
            customer_policy_path = lookup(customer_policy, "path", null)
            name = k
        } if length(v) > 0 }
        ]...)
    instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
    permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
    permissions_boundary {
        customer_managed_policy_reference {
            name = lookup(each.value, "customer_policy_name")
            path = lookup(each.value, "customer_policy_path")
        }
    }
}
# Attach aws managed permissions boundaries
resource "aws_ssoadmin_permissions_boundary_attachment" "default_aws" {
    for_each = merge([for k, v in local.aws_managed_permissions_boundaries:{
        for arn in lookup(v, "managed_policy_arn") : "${k}/${arn}" => {
            arn = arn
            name = k
        } if length(v) > 0 }
        ]...)
    instance_arn = tolist(data.aws_ssoadmin_instances.default.arns)[0]
    permission_set_arn = aws_ssoadmin_permission_set.default[lookup(each.value, "name")].arn
    permissions_boundary {
        managed_policy_arn = lookup(each.value, "arn")
    }
}

# Attach permission set to account
#resource "aws_ssoadmin_account_assignment" "default" {
#    for each 
#}