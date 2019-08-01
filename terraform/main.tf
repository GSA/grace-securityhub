data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  app_name   = "grace-securityhub"
  account_id = "${data.aws_caller_identity.current.account_id}"
  region     = "${data.aws_region.current.name}"
}
