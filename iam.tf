resource "aws_iam_role" "iam_role" {
  name        = local.app_name
  description = "Role for GRACE SecHub Lambda function"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "iam_policy" {
  name        = local.app_name
  description = "Policy to allow GRACE SecHub lambda permission to query accounts, create/invite members, and accept tenant side invitations"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "securityhub:*",
        "cloudwatch:DescribeAlarms",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
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
        "${aws_iam_role.iam_role.arn}",
        "arn:aws:iam::${var.master_account_id}:role/${var.master_role_name}",
        "arn:aws:iam::*:role/${var.tenant_role_name}"
      ]
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}