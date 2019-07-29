variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "treat_missing_data" {
  description = "value used by all aws_cloudwatch_metric_alarm for the treat_missing_data property"
  default     = "ignore"
}

variable "env" {
  description = "AWS region to launch servers."
  default     = "sandbox"
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "cloudtrail_kms_key" {
  description = "ARN of cloudtrail KMS key"
}

variable "cloudwatch_delivery_role_arn" {
  description = "cloudwatch_delivery_role ARN"
}

variable "cloudwatch_delivery_role_id" {
  description = "cloudwatch_delivery_role ID"
}

variable "cloudwatch_logs_group_name" {
  description = "cloud watch log group name"
  default     = "GRACE-cloudtrail-multi-region"
}

variable "iam_role_policy_name" {
  description = "The name of the IAM Role Policy to be used by CloudTrail to delivery logs to CloudWatch Logs group."
  default     = "grace-cloudwatch-delivery-role-policy"
}

variable "aws_account_id" {
  description = "aws account ID"
}

variable "master_aws_account_id" {
  description = "aws account ID"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Number of days to retain logs for. CIS recommends 365 days.  Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. Set to 0 to keep logs indefinitely."
  default     = 365
}

variable "key_deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. Defaults to 30 days."
  default     = 10
}

variable "alarm_namespace" {
  description = "The namespace in which all alarms are set up."
  default     = "GRACECISBenchmark"
}

variable "sns_topic_name" {
  description = "The name of the SNS Topic which will be notified when any alarm is performed."
  default     = "GRACE_cloudwatch_notifications"
}

variable "additional_tags" {
  default     = {}
  description = "The tags to apply to resources created by this module"
  type        = "map"
}

variable "display_name" {
  type        = "string"
  description = "Name shown in confirmation emails"
  default     = "GRACE Monitoring"
}

variable "email_address" {
  type        = "string"
  description = "Email address to send notifications to"
}

variable "owner" {
  type        = "string"
  description = "Sets the owner tag on the CloudFormation stack"
  default     = "tf_sns_email"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
}

variable "stack_name" {
  type        = "string"
  description = "Cloudformation stack name that wraps the SNS topic. Must be unique."
  default     = "tf-sns-email"
}

variable "sns_topic_name_alarms" {
  description = "The name of the SNS Topic which will be notified when any alarm is triggered."
  default     = "GRACE_cloudwatch_alarm_notifications"
}

variable "display_name_alarms" {
  type        = "string"
  description = "Name shown in confirmation emails"
  default     = "GRACE Monitoring Alarms"
}

variable "stack_name_alarms" {
  type        = "string"
  description = "Cloudformation stack name that wraps the SNS topic. Must be unique."
  default     = "tf-sns-alarms-email"
}

variable "dev" {
  description = "AWS region to launch servers."
  default     = "development"
}
