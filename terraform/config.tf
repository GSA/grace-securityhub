resource "aws_iam_role" "config" {
  name = "${var.aws_config_role_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "config" {
  role = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "organization" {
  role = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_recorder" "config" {
  name = "${var.aws_config_recorder_name}"
  role_arn = "${aws_iam_role.config.arn}"
  recording_group {
    all_supported = "${var.aws_config_recorder_group_all_supported}"
    include_global_resource_types = "${var.aws_config_recorder_group_include_global}"
  }
}

resource "aws_config_delivery_channel" "config" {
  name = "${var.aws_config_delivery_name}"
  s3_bucket_name = "${var.aws_config_delivery_bucket}"
  s3_key_prefix = "${var.aws_config_delivery_bucket_prefix}"

  snapshot_delivery_properties {
    delivery_frequency = "${var.aws_config_delivery_frequency}"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

resource "aws_config_configuration_recorder_status" "config" {
  name = "${aws_config_configuration_recorder.config.name}"

  is_enabled = "${var.aws_config_recorder_enabled}"

  depends_on = ["aws_config_delivery_channel.config"]
}
