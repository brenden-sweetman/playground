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
    test2 = {
      name        = "test2_customer_managed_policies"
      description = "Test permission_set"
      inline_policies = [
        {
          sid       = "AllowAll"
          effect    = "Allow"
          actions   = ["*"]
          resources = ["*"]
        }
      ]
      customer_managed_policies = [ 
        {
          name = aws_iam_policy.example1.name
          path = "/"
        },
        {
          name = aws_iam_policy.example2.name
          path = "/"
        },
      ]
    }
    test3 = {
      name        = "test3_aws_managed_policies"
      description = "Test permission_set"
      inline_policies = [
        {
          sid       = "AllowAll"
          effect    = "Allow"
          actions   = ["*"]
          resources = ["*"]
        }
      ]
      customer_managed_policies = [ 
        {
          name = aws_iam_policy.example1.name
          path = "/"
        },
        {
          name = aws_iam_policy.example2.name
          path = "/"
        },
      ]
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AWSIoT1ClickReadOnlyAccess",
        "arn:aws:iam::aws:policy/job-function/SupportUser"
      ]
    }
    test4 = {
      name        = "test4_customer_managed_pb"
      description = "Test permission_set"
      inline_policies = [
        {
          sid       = "AllowAll"
          effect    = "Allow"
          actions   = ["*"]
          resources = ["*"]
        }
      ]
      customer_managed_policies = [ 
        {
          name = aws_iam_policy.example1.name
          path = "/"
        },
        {
          name = aws_iam_policy.example2.name
          path = "/"
        },
      ]
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AWSIoT1ClickReadOnlyAccess",
        "arn:aws:iam::aws:policy/job-function/SupportUser",
      ]
      customer_managed_permissions_boundary = {
          name = aws_iam_policy.example1.name
          path = "/"
        }
    }
    test5 = {
      name        = "test5_aws_managed_pb"
      description = "Test permission_set"
      inline_policies = [
        {
          sid       = "AllowAll"
          effect    = "Allow"
          actions   = ["*"]
          resources = ["*"]
        }
      ]
      customer_managed_policies = [ 
        {
          name = aws_iam_policy.example1.name
          path = "/"
        },
        {
          name = aws_iam_policy.example2.name
          path = "/"
        },
      ]
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AWSIoT1ClickReadOnlyAccess",
        "arn:aws:iam::aws:policy/job-function/SupportUser",
      ]
      aws_managed_permissions_boundary = "arn:aws:iam::aws:policy/job-function/SupportUser"
    }
  }

}


## Customer_managed_policies resources:
resource "aws_iam_policy" "example1" {
  name        = "TestPolicy1"
  description = "My test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_policy" "example2" {
  name        = "TestPolicy2"
  description = "My test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:RunInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}