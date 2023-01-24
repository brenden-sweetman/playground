output "identity_store_id" {
  description = "The ID of the AWS SSO Identity store"
  value       = tolist(data.aws_ssoadmin_instances.default.identity_store_ids)[0]
}

output "permission_sets" {
  description = "A map of all permission sets defined in module"
  value =  aws_ssoadmin_permission_set.default
}

