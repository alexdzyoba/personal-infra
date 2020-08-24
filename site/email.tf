data "aws_region" "current" {}

resource "aws_s3_bucket" "emails" {
  bucket = "dzyoba-com-emails"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name    = "Emails"
    Project = "email"
  }
}

resource "aws_s3_bucket_public_access_block" "emails_block_public_access" {
  bucket = aws_s3_bucket.emails.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_policy "allow_ses_put" {
  bucket = aws_s3_bucket.emails.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSESPut",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.emails.id}/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": "${var.master_account_id}"
                }
            }
        }
    ]
}
EOF
}

resource "aws_ses_domain_identity" "site" {
  domain = aws_route53_zone.site.name
}

resource "aws_route53_record" "ses_site_verification" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.site.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.site.verification_token]
}

resource "aws_route53_record" "dkim" {
  count = 3

  zone_id = aws_route53_zone.site.zone_id
  name    = "${element(aws_ses_domain_dkim.site.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.site.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_domain_dkim" "site" {
  domain = aws_ses_domain_identity.site.domain
}

resource aws_lambda_function "forwarder" {
  function_name = "ses-forwarder"

  s3_bucket = "dzyoba-com-emails"
  s3_key    = "forwarder.zip"

  runtime = "nodejs12.x"
  handler = "index.handler"

  role = aws_iam_role.lambda_forwarder.arn

  timeout = 30
}

resource aws_iam_role "lambda_forwarder" {
  name = "LambdaSESForwarder"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "allow_logs_ses_s3" {
  name = "AllowLogsSESS3"
  role = aws_iam_role.lambda_forwarder.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowS3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.emails.id}/*"
    },
    {
      "Sid": "AllowSESSend",
      "Effect": "Allow",
      "Action": "ses:SendRawEmail",
      "Resource": "arn:aws:ses:${data.aws_region.current.name}:${var.master_account_id}:identity/*"
    }
  ]
}
EOF
}

resource "aws_ses_receipt_rule_set" "store_forward_set" {
  rule_set_name = "StoreAndForwardRuleSet"
}

resource "aws_ses_receipt_rule" "store_forward" {
  name          = "StoreAndForward"
  rule_set_name = aws_ses_receipt_rule_set.store_forward_set.rule_set_name
  enabled       = true

  scan_enabled = true

  s3_action {
    position = 1

    bucket_name       = aws_s3_bucket.emails.id
    object_key_prefix = var.email_bucket_prefix
  }

  lambda_action {
    position = 2

    function_arn = aws_lambda_function.forwarder.arn
  }

  depends_on = [
    aws_lambda_permission.allow_ses
  ]
}

resource "aws_ses_active_receipt_rule_set" "activate_store_forward" {
  rule_set_name = aws_ses_receipt_rule_set.store_forward_set.rule_set_name
}

resource "aws_lambda_permission" "allow_ses" {
  statement_id   = "AllowExecutionFromSES"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.forwarder.function_name
  principal      = "ses.amazonaws.com"
  source_account = var.master_account_id
}

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.site.zone_id
  name    = aws_ses_domain_identity.site.domain
  type    = "MX"
  ttl     = "600"
  records = [
    "10 inbound-smtp.${data.aws_region.current.name}.amazonaws.com"
  ]
}

resource aws_ses_email_identity "sender" {
  email = "alex.dzyoba@gmail.com"
}
