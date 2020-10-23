variable "appenv" {
  type        = string
  description = "(optional) The environment in which the script is running (development | test | production)"
  default     = "development"
}

variable "project_name" {
  type        = string
  description = "(required) project name (e.g. grace, fcs, fas, etc.). Used as prefix for AWS S3 bucket name"
  default     = "grace"
}

variable "source_file" {
  type        = string
  description = "(optional) full or relative path to zipped binary of lambda handler"
  default     = "../release/grace-sechub-lambda.zip"
}

variable "master_role_name" {
  type        = string
  description = "(optional) Role assumed by lambda function to query organizations in Master Payer account"
  default     = ""
}

variable "master_account_id" {
  type        = string
  description = "(optional) Account ID of AWS Master Payer Account"
  default     = ""
}

variable "organizational_ou" {
  type        = string
  description = "(optional) The AWS Organizations OU where member accounts live"
  default     = ""
}

variable "schedule_expression" {
  type        = string
  description = "(optional) Cloudwatch schedule expression for when to run sechub lambda"
  default     = "cron(5 3 ? * MON-FRI *)"
}
