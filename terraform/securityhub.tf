data "aws_region" "current" {}
resource "aws_securityhub_account" "account" {}

resource "aws_securityhub_standards_subscription" "cis" {
  count         = "${var.securityhub_enable_cis_benchmark ? 1 : 0}"
  depends_on    = ["aws_securityhub_account.account"]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

resource "aws_securityhub_product_subscription" "guardduty" {
  count       = "${var.securityhub_enable_guardduty ? 1 : 0}"
  depends_on  = ["aws_securityhub_account.account"]
  product_arn = "arn:aws:securityhub:${var.region}::product/aws/guardduty"
}
resource "aws_guardduty_detector" "guardduty" {
  enable                       = "${var.guardduty_enable}"
  finding_publishing_frequency = "${var.guardduty_frequency}"
}
