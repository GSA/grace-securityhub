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
