output "env" {
  value = "${var.appenv}"
}

output "name" {
  value = "grace-${var.appenv}-securityhub"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

data "aws_kms_key" "kms_key" {
  key_id = "alias/grace-${var.appenv}-config"
}

output "config_kms_key" {
  value = "${data.aws_kms_key.kms_key.arn}"
}
