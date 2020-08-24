variable master_account_id {
  description = "Master account id that is trusted by OrganizationAccountAccessRole"
  type        = string
}

variable google_analytics_verification_record {
  description = "Unique string value for TXT DNS record to verify domain for Google Analytics"
  type        = string
}

variable gitlab_pages_verification_record {
  description = "Unique string value for TXT DNS record to verify domain for Gitlab Pages"
  type        = string
}

variable email_bucket_prefix {
  description = "S3 bucket prefix to store emails"
  type        = string
  default     = "emails/"
}
