variable "permission_sets" {
  description = "A complex map with permissions and statements for SSO permission_sets"
  type = map(object({
    name             = optional(string)
    description      = optional(string)
    relay_state      = optional(string)
    session_duration = optional(string)
    inline_policies = optional(list(object({
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
  default = {}
}

variable "ou_to_group_mapping" {
  description = "A map of organization OUs to IDP groups and the connecting permission set"
  type = map(list(object({
    idp_group           = string
    permission_set_name = string
  })))
  default = {}
}

variable "tags" {
  description = "A map of tags to associate with all resources"
  type        = map(string)
  default     = {}
}