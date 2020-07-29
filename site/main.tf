terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alexdzyoba"

    workspaces {
      name = "site"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-north-1"

  # Access this AWS account by assuming role for user in master account.
  # OrganizationAccountAccessRole is created by default for accounts in
  # organization.
  profile = "personal"
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/OrganizationAccountAccessRole"
  }
}
