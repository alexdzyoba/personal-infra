provider "aws" {
  version = "~> 2.0"
  region  = "eu-north-1"
}

resource "aws_organizations_organization" "personal-infra" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
  ]

  feature_set = "ALL"
}

# This is the organization master account. It was imported with
# terraform import aws_organizations_account.master <account id>
resource "aws_organizations_account" "master" {
  name  = "Alex Dzyoba"
  email = "alex.dzyoba@gmail.com"
}

resource "aws_organizations_account" "counter64" {
  name  = "counter64"
  email = "alex.dzyoba+counter64@gmail.com"
}
