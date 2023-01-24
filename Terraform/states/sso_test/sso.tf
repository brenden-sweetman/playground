module "sso" {
    source = "../../modules/aws_sso"
    permission_sets = {
        test1 = {
            name = "test1"
            description = "Test permission_set"
            inline_policies = [
                {
                    sid = "Allow All"
                    effect = "Allow"
                    actions = ["*"]
                    resources = ["*"]
                }
            ]
        }
    }
  
}