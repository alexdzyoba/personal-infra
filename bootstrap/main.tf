terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "alexdzyoba"

    workspaces {
      name = "bootstrap"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.13"
}

provider "aws" {
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

# For VPN
resource "aws_organizations_account" "vpn" {
  name  = "vpn"
  email = "alex.dzyoba+vpn@gmail.com"
}

resource "aws_key_pair" "ssh" {
  key_name   = "main"
  public_key = var.ssh_key
}
