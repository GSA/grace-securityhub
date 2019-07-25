
variable "regions" {
  type        = "string"
  description = "(optional) Comma delimited list of AWS regions to inventory"
  default     = "us-east-1,us-east-2,us-west-1,us-west-2"
}
variable "appenv" {
  type        = "string"
  description = "(optional) The environment in which the script is running (development | test | production)"
  default     = "development"
}
