variable "permission_sets" {
  description = "A complex map with permissions and statements for SSO permission_sets"
  # Optional types below pass a null value if the attribute is missing in the module call.
  # The module takes advantage of the coalesce() function as empty lists/maps are generally
  # preferred when using for_each
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    relay_state      = optional(string)
    session_duration = optional(string)
    account_ids = optional(list(string))
    sso_groups = optional(list(string))
    inline_policy_statements = optional(list(object({
      sid           = string
      effect        = string
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      resources     = optional(list(string))
      not_resources = optional(list(string))
      conditions = optional(list(object({
        test     = string
        variable = string
        values   = list(string)
      })))
    })))
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string)
    })))
    aws_managed_policies = optional(list(string))
    customer_managed_permissions_boundary = optional(object({
        name = string
        path = string
    }))
    aws_managed_permissions_boundary = optional(string)
  }))
  validation {
    condition = var.customer_managed_permissions_boundary != null && var.aws_managed_permissions_boundary != null
    error_message = "Only one permissions boundary can be specified. You specified both a aws_managed_permissions_boundary and a customer_managed_permissions_boundary choose 1."
  }
  default = {}
}


variable "tags" {
  description = "A map of tags to associate with all resources"
  type        = map(string)
  default     = {}
}