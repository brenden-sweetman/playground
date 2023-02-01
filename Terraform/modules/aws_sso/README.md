# AWS SSO module

## Introduction
This module provisions IAM Identity Center permission sets and group/account associations. You may notice the module essentially uses one primary variable for practically all inputs. This allows the module to use extensive for_each operations to support the numerous roles needed for comprehensive identity design. The module also supports passing IAM policies as Terraform map objects instead of separate json. Designed this way to easily pair with other modules, like a paired Identity Provider module, without having to parse json. More info on passing IAM polices as Terraform map objects can be found below.

## Module Structure
The core resource of IAM Identity Center are permission sets. The permission sets can be paired with the following resources to provide the sets IAM permissions:

* `aws_ssoadmin_permission_set_inline_policy` When paired with a `aws_iam_policy_document` data object the inline policy attaches directly to the permission set. The IAM permissions work exactly the same as any IAM role. This module builds the policy document from the `inline_policy_statements` list object in the `permission_sets` variable. Multiple statements can be added to the list as needed. 
* `aws_ssoadmin_customer_managed_policy_attachment` This resources allows the attachment of an existing customer managed IAM policy to the permission set. Multiple customer managed policies can be attaches from the `customer_managed_policies` list object in the `permission_sets` variable. **NOTE: The customer managed policy must be deployed in all associated AWS accounts for role provisioning to work.**
* `aws_ssoadmin_managed_policy_attachment` This resources allows attachment of an AWS managed policy to the permission set. Multiple customer managed policies can be attaches from the `aws_managed_policies` list object in the `permission_sets` variable.
* `aws_ssoadmin_permissions_boundary_attachment` This resource allows attachment of a permissions boundary to the permission set. Due to the varying attribute arrangement for customer managed policies and aws manages policies, customer managed policies should be added to the `customer_managed_permissions_boundary` object and AWS managed policies should be added to the `aws_managed_permissions_boundary` object in the `permission_sets` variable. **NOTE: only one permissions boundary can be associated to a permission set at a time. If you are adding a permissions boundary with a customer manages policy the policy must be provisioned in all associated AWS accounts.**

Once all policies and boundaries are added to the set the module will assign the sets to both AWS account access and the identiystore group(s) associated with the permission sets. The accounts and groups are specified in the `account_ids` and `sso_groups` strings of the `permission_sets` variable. 

## A few considerations for this module
1. This module does not support attachment of identitystore users to permission sets all attachments should happen at the group level to maintain simplicity. 

## TODO:
* Instead of passing a list of every account ID for a permission set I hope this module can be updated in the future to support attachment of a permission set to all child accounts in an organization OU. Further info can be found in this issue: https://github.com/hashicorp/terraform-provider-aws/issues/16153 and PR: https://github.com/hashicorp/terraform-provider-aws/pull/24350