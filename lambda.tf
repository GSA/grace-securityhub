
resource "aws_sns_topic" "lambda" {
  name = "${var.lambda_sns_topic_name}"
}

resource "aws_sns_topic_policy" "lambda" {
  arn = "${aws_sns_topic.lambda.arn}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
      {
          "Sid": "__default_statement_ID",
          "Effect": "Allow",
          "Principal": "*",
          "Action": [
              "SNS:Publish"
          ],
          "Resource": "${aws_sns_topic.lambda.arn}",
          "Condition": {
              "StringEquals": {
                  "AWS:SourceOwner": "${local.account_id}"
              }
          }
      }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.lambda.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
}

resource "aws_lambda_function" "lambda" {
  filename         = "${var.lambda_source_file}"
  function_name    = "${var.lambda_name}"
  description      = "A Lambda for converting events to SecurityHub Findings"
  role             = "${aws_iam_role.lambda.arn}"
  handler          = "grace-securityhub"
  source_code_hash = "${filesha256(var.lambda_source_file)}"
  kms_key_arn      = "${aws_kms_key.lambda.arn}"
  runtime          = "go1.x"
  timeout          = 900
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.lambda.arn}"
}

resource "aws_iam_role" "lambda" {
  name        = "${var.lambda_iam_role_name}"
  description = "Role for GRACE Inventory Lambda function"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.lambda_iam_policy_name}"
  description = "Policy to allow creating new SecurityHub findings"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "securityhub:BatchImportFindings"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "sts:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_iam_role.lambda.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt"
      ],
      "Resource": [
        "${aws_kms_key.lambda.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = "${aws_iam_role.lambda.name}"
  policy_arn = "${aws_iam_policy.lambda.arn}"
}
resource "aws_kms_key" "lambda" {
  description             = "KMS Key for encrypting the lambda at rest"
  deletion_window_in_days = 7
  enable_key_rotation     = "true"
  depends_on              = ["aws_iam_role.lambda"]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow use of the key",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda.arn}"
        ]
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "lambda" {
  name          = "alias/${var.lambda_kms_key_alias_prefix}-${local.account_id}" # Key Alias must be unique to account and region
  target_key_id = "${aws_kms_key.lambda.key_id}"
}
