variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "aws account ID"
}

variable "master_aws_account_id" {
  description = "aws account ID"
}

variable "config_kms_key" {
  description = "kms config keys"
}

variable "name" {
  description = "app name"
}

variable "acl" {
  description = "bucket acl"
  default     = "log-delivery-write"
}

variable "enable_versioning" {
  description = "enable bucket versioning"
  default     = "true"
}

variable "tags" {
  description = "tags"
  default     = {}
}

variable "glacier_days" {
  description = "enable bucket versioning"
  default     = "365"
}

variable "lifecycle_prefix" {
  description = "enable bucket versioning"
  default     = "awslog/"
}

variable "aws_config_bucket_key_prefix" {
  description = "enable bucket versioning"
  default     = "awsconfig"
}

variable "iam_role_name" {
  description = "The name of the IAM Role to be used by CloudTrail to delivery logs to CloudWatch Logs group."
  default     = "grace-cloudwatch-delivery"
}

variable "iam_role_policy_name" {
  description = "The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group."
  default     = "grace-cloudwatch-delivery-role-policy"
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 10
}

variable "additional_tags" {
  default     = {}
  description = "The tags to apply to resources created by this module"
  type        = "map"
}

variable "config_bucket" {
  description = "config bucket name"
}

variable "env" {
  description = "AWS region to launch servers."
  default     = "sandbox"
}
