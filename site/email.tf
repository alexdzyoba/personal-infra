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

resource "aws_ses_domain_identity" "site" {
  domain = aws_route53_zone.site.name
}

resource "aws_route53_record" "example_amazonses_verification_record" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.site.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.site.verification_token]
}

resource "aws_ses_domain_dkim" "site" {
  domain = aws_ses_domain_identity.site.domain
}

resource "aws_route53_record" "dkim" {
  count = 3

  zone_id = aws_route53_zone.site.zone_id
  name    = "${element(aws_ses_domain_dkim.site.dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.site.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
