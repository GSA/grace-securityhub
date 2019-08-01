output securityhub_id {
  value = "${aws_securityhub_account.account.id}"
}

output securityhub_cis_id {
  value = "${aws_securityhub_standards_subscription.cis.id}"
}
output securityhub_guardduty_arn {
  value = "${aws_securityhub_product_subscription.guardduty.arn}"
}

output guardduty_detector_id {
  value = "${aws_guardduty_detector.guardduty.id}"
}
output guardduty_detector_account_id {
  value = "${aws_guardduty_detector.guardduty.account_id}"
}
