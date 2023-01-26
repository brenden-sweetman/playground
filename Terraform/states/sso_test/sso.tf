module "sso" {
  source = "../../modules/aws_sso"
  permission_sets = {
    test1 = {
      name        = "test1_all_perms"
      description = "Test permission_set"
      inline_policies = [
        {
          sid       = "AllowAll"
          effect    = "Allow"
          actions   = ["*"]
          resources = ["*"]
        }
      ]
    }
  }

}