data "aws_organizations_organization" "example" {}

data "aws_organizations_organizational_units" "root" {
  parent_id = data.aws_organizations_organization.example.roots[0].id
}

locals {
    ou = "o-387msfvvsq"
    ou_accounts = [for account in data.aws_organizations_organization.example.accounts[*]:
    account.id if can(regex(local.ou,account.arn)) ] 
}


output "account_ids" {
  value = data.aws_organizations_organization.example
}

output "ou_account_ids" {
    value = local.ou_accounts
}

output "root_ous" {
    value = data.aws_organizations_organizational_units.root.children
}