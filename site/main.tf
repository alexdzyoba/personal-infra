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
  region  = "eu-central-1"

  # Access this AWS account by assuming role for user in master account.
  # OrganizationAccountAccessRole is created by default for accounts in
  # organization.
  profile = "personal"
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/OrganizationAccountAccessRole"
  }
}

resource "aws_route53_zone" "site" {
  name = "dzyoba.com"
}

resource "aws_route53_record" "alex" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "alex"
  type    = "CNAME"
  ttl     = "10800"
  records = ["dzeban.gitlab.io"]
}

resource "aws_route53_record" "gitlab_pages_verification" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "_gitlab-pages-verification-code.alex"
  type    = "TXT"
  ttl     = "10800"
  records = [
    var.gitlab_pages_verification_record
  ]
}

resource "aws_route53_record" "google_analytics_verification" {
  zone_id = aws_route53_zone.site.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "10800"
  records = [
    var.google_analytics_verification_record
  ]
}
