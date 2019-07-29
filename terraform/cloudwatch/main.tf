provider "aws" {}

module "sns" {
  source              = "./SNS"
  additional_tags     = "${var.additional_tags}"
  display_name        = "${var.display_name}"
  email_address       = "${var.email_address}"
  protocol            = "${var.protocol}"
  stack_name          = "${var.stack_name}"
  display_name_alarms = "${var.display_name_alarms}"
  stack_name_alarms   = "${var.stack_name_alarms}"
}
