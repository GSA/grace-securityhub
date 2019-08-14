variable "securityhub_enable" {
  description = "(optional) The boolean value of whether to enable SecurityHub for the current account"
  default     = "true"
}

variable "securityhub_enable_cis_benchmark" {
  description = "(optional) The boolean value of whether to enable the CIS Benchmark ruleset"
  default     = "true"
}

variable "securityhub_enable_guardduty" {
  description = "(optional) The boolean value of whether to enable the guardduty product for SecurityHub"
  default     = "true"
}

variable "guardduty_enable" {
  description = "(optional) The boolean value of whether to enable the GuardDuty Detector"
  default     = "true"
}

variable "guardduty_frequency" {
  description = "(optional) Specifies the frequency of notifications sent for subsequent finding occurrences. (see: https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency)"
  default     = "ONE_HOUR"
}

variable "config_role_name" {
  description = "(optional) The name given to the IAM role created for AWS Config"
  default     = "grace-config-service"
}

variable "config_recorder_enable" {
  description = "(optional) The boolean value indicating whether or not to deploy the AWS Config Recorder and its configuration"
  default     = "true"
}

variable "config_recorder_name" {
  description = "(optional) The name given to the AWS Config Recorder"
  default     = "grace-config-service"
}

variable "config_recorder_enabled" {
  description = "(optional) The boolean value indicating whether or not to enable AWS Config Recorder"
  default     = "true"
}
variable "config_delivery_name" {
  description = "(optional) The name given to the AWS Config Delivery Channel"
  default     = "grace-config-service"
}
variable "config_delivery_bucket" {
  description = "(required) The name of the S3 bucket that should receive AWS Config Recorder logs"
}

variable "config_delivery_bucket_prefix" {
  description = "(optional) The prefix used when delivering logs to the aws_config_delivery_bucket"
  default     = "grace-config-service"
}

variable "config_delivery_frequency" {
  description = "(optional) The frequency with which AWS Config recurringly delivers configuration snapshots (see: https://docs.aws.amazon.com/config/latest/APIReference/API_ConfigSnapshotDeliveryProperties.html#API_ConfigSnapshotDeliveryProperties_Contents)"
  default     = "One_Hour"
}

variable "config_recorder_group_all_supported" {
  description = "(optional) Specifies whether AWS Config records configuration changes for every supported type of regional resource (which includes any new type that will become supported in the future)."
  default     = "true"
}

variable "config_recorder_group_include_global" {
  description = "(optional) Specifies whether AWS Config includes all supported types of global resources with the resources that it records."
  default     = "true"
}

variable "lambda_name" {
  description = "(optional) The name given to the Lambda function"
  default     = "grace-securityhub"
}

variable "lambda_iam_role_name" {
  description = "(optional) The name given to the Lambda IAM Role"
  default     = "grace-securityhub"
}
variable "lambda_iam_policy_name" {
  description = "(optional) The name given to the Lambda IAM Policy"
  default     = "grace-securityhub"
}

variable "lambda_invoker_iam_role_name" {
  description = "(optional) The name given to the Lambda Invoker IAM Role"
  default     = "grace-securityhub-invoker"
}
variable "lambda_invoker_iam_policy_name" {
  description = "(optional) The name given to the Lambda Invoker IAM Policy"
  default     = "grace-securityhub-invoker"
}

variable "lambda_kms_key_alias_prefix" {
  description = "(optional) The prefix used in the KMS Key Alias, the suffix is the current account ID"
  default     = "grace-securityhub"
}

variable "lambda_source_file" {
  type        = "string"
  description = "(optional) The full or relative path to zipped binary of lambda handler"
  default     = "../release/grace-securityhub.zip"
}

variable "lambda_sns_topic_name" {
  description = "(optional) The name of the SNS topic used to send events to the SecurityHub Lambda"
  default     = "grace-securityhub-topic"
}
