variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "name" {
  description = "app name"
}

variable "env" {
  description = "app environment"
  default     = "sandbox"
}

variable "aws_config_bucket_key_prefix" {
  description = "enable bucket versioning"
  default     = "awsconfig"
}

variable "aws_account_id" {
  description = "aws account ID"
}

variable "access_bucket" {
  description = "bucket name"
}
