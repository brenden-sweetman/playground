output "identity_store_id" {
  description = "The ID of the AWS SSO Identity store"
  value       = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

output "permission_sets" {
  description = "A map of all permission sets defined in module"
  value       = aws_ssoadmin_permission_set.default
}

output "inline_policies" {
  value = local.inline_policies
}
output customer_managed_policies {
  value = local.customer_managed_policies
}
output "aws_managed_policies" {
  value = local.aws_managed_policies
}

output "customer_managed_permissions_boundary" {
  value = local.customer_managed_permissions_boundary
}

output "aws_managed_permissions_boundary" {
  value = local.aws_managed_permissions_boundary
}