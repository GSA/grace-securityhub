output securityhub_id {
  value = "${aws_securityhub_account.account.id}"
}

output securityhub_cis_id {
  value = "${aws_securityhub_standards_subscription.cis.0.id}"
}
output securityhub_guardduty_arn {
  value = "${aws_securityhub_product_subscription.guardduty.0.arn}"
}

output guardduty_detector_id {
  value = "${aws_guardduty_detector.guardduty.0.id}"
}
output guardduty_detector_account_id {
  value = "${aws_guardduty_detector.guardduty.0.account_id}"
}

output securityhub_lambda_arn {
  value = "${aws_lambda_function.lambda.arn}"
}
output securityhub_lambda_kms_key_arn {
  value = "${aws_kms_key.lambda.arn}"
}
output securityhub_lambda_kms_key_id {
  value = "${aws_kms_key.lambda.key_id}"
}
output securityhub_lambda_role_arn {
  value = "${aws_iam_role.lambda.arn}"
}
output securityhub_lambda_role_id {
  value = "${aws_iam_role.lambda.id}"
}
output securityhub_lambda_role_name {
  value = "${aws_iam_role.lambda.name}"
}
output securityhub_lambda_kms_key_alias_arn {
  value = "${aws_kms_alias.lambda.arn}"
}
output securityhub_lambda_kms_key_alias_target_arn {
  value = "${aws_kms_alias.lambda.target_key_arn}"
}
output securityhub_lambda_sns_topic_arn {
  value = "${aws_sns_topic.lambda.arn}"
}
