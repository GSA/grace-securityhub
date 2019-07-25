output cloudtrail_kms_key {
  value = "${aws_kms_key.cloudtrail.arn}"
}

output bucket_name {
  value = "${aws_s3_bucket.grace-logging.bucket}"
}
