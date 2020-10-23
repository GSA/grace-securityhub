data "aws_caller_identity" "identity" {}
data "aws_region" "region" {}

locals {
  app_name   = "${var.project_name}-${var.appenv}-sechub"
  account_id = "${data.aws_caller_identity.identity.account_id}"
  region     = "${data.aws_region.region.name}"
}
