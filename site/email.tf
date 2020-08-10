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
