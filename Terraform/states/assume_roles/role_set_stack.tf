resource "aws_cloudformation_stack_set" "default" {
    name = "AdminRoleAssume"
    template_body = <<TEMPLATE
{
  "Resources" : {
    "AdminRole": {
      "Type" : "AWS::IAM::Role",
      "Properties" : {
        "AssumeRolePolicyDocument" : {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {
                                "AWS": [
                                    "arn:aws:iam::908121969653:user/brenden"
                                ]
                            },
                            "Action": [
                                "sts:AssumeRole"
                            ]
                        }
                    ]
                },
        "Description" : "Test Role for Assume",
        "MaxSessionDuration" : 3600,
        "Path" : "/",
        "Policies" : [ {
                        "PolicyName": "Admin_MFA",
                        "PolicyDocument": {
                            "Version": "2012-10-17",
                            "Statement": [
                                {
                                    "Effect": "Allow",
                                    "Action": "*",
                                    "Resource": "*",
                                    "Condition": {
                                        "Bool": {
                                            "aws:MultiFactorAuthPresent": "false"
                                        }
                                    }    
                                }
                            ]
                        }
                    }
            
        ],
        "RoleName" : "Administrator"
      }
    }
  }
}
TEMPLATE
}

resource "aws_cloudformation_stack_set_instance" "default" {
    deployment_targets {
      organizational_unit_ids = ["ou-qolo-3m90hd4d"]
    }
    stack_set_name = aws_cloudformation_stack_set.default.name
}
