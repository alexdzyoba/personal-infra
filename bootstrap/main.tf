terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alexdzyoba"

    workspaces {
      name = "bootstrap"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-north-1"
  profile = "personal"
}

# Organizations
resource "aws_organizations_organization" "personal-infra" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
  ]

  feature_set = "ALL"
}

# This is the organization master account.
# All other resources in this terraform module is created in this account.
resource "aws_organizations_account" "master" {
  name  = "Alex Dzyoba"
  email = "alex.dzyoba@gmail.com"
}

resource "aws_organizations_account" "counter64" {
  name  = "counter64"
  email = "alex.dzyoba+counter64@gmail.com"
}

# For dzyoba.com blog and email infra
resource "aws_organizations_account" "site" {
  name  = "site"
  email = "alex.dzyoba+site@gmail.com"
}

resource "aws_key_pair" "ssh" {
  key_name   = "main"
  public_key = var.ssh_key
}
