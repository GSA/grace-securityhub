#IAM ROLE for AWS Config
resource "aws_iam_role" "config" {
  name = "grace-config-service"

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

#IAM Policy for AWS Config
resource "aws_iam_role_policy_attachment" "config" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "organization" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_recorder" "config" {
  name     = "config-service"
  role_arn = "${aws_iam_role.config.arn}"
  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types = [
  	"AWS::CloudTrail::Trail",
  	"AWS::IAM::Group",
  	"AWS::IAM::Policy",
  	"AWS::IAM::Role", 
  	"AWS::IAM::User",
  	"AWS::S3::Bucket", 
  	"AWS::CloudWatch::Alarm",
  	"AWS::CloudFormation::Stack",
  	"AWS::Lambda::Function",
  	"AWS::Config::ResourceCompliance"
     ]
  }
}

#Create Recorder
resource "aws_config_delivery_channel" "config" {
  name           = "config-service"
  s3_bucket_name = "${var.name}"
  s3_key_prefix  = "${var.aws_config_bucket_key_prefix}"

  snapshot_delivery_properties {
    delivery_frequency = "Three_Hours"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

resource "aws_config_configuration_recorder_status" "config" {
  name       = "${aws_config_configuration_recorder.config.name}"
  is_enabled = true

  depends_on = ["aws_config_delivery_channel.config"]
}

#cloudwatch_alarm_action_check

resource "aws_config_config_rule" "cloudwatch_alarm_action_check" {
  name = "grace-${var.env}-cloudwatch-alarm-action-check"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_ALARM_ACTION_CHECK"
  }

  input_parameters = <<EOF
{
  "alarmActionRequired" : "true",
  "insufficientDataActionRequired" : "false",
  "okActionRequired" : "false"
}
EOF

  depends_on = ["aws_config_configuration_recorder.config"]
}

#Create Config rules for CT enabled
resource "aws_config_config_rule" "cloud_trail_enabled" {
  name = "grace-${var.env}-cloud-trail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#iam_password_policy

resource "aws_config_config_rule" "iam_password_policy" {
  name = "grace-${var.env}-iam-password-policy"

  source {
    owner             = "AWS"
    source_identifier = "IAM_PASSWORD_POLICY"
  }

  input_parameters = <<EOF
{
  "RequireUppercaseCharacters" : "true",
  "RequireLowercaseCharacters" : "true",
  "RequireSymbols" : "true",
  "RequireNumbers" : "true",
  "MinimumPasswordLength" : "16",
  "PasswordReusePrevention" : "10",
  "MaxPasswordAge" : "90"
}
EOF

  depends_on = ["aws_config_configuration_recorder.config"]
}

#Ct Encrption
resource "aws_config_config_rule" "cloud_trail_encryption_enabled" {
  name        = "grace-${var.env}-cloud-trail-encryption-enabled"
  description = "Checks whether AWS CloudTrail is configured to use the server side encryption (SSE) AWS Key Management Service (AWS KMS) customer master key (CMK) encryption. The rule is COMPLIANT if the KmsKeyId is defined."

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENCRYPTION_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#mfa-enabled-for-iam-console-access
resource "aws_config_config_rule" "mfa-enabled-for-iam-console-access" {
  name        = "grace-${var.env}-mfa-enabled-for-iam-console-access"
  description = "Checks whether AWS Multi-Factor Authentication (MFA) is enabled for all AWS Identity and Access Management (IAM) users that use a console password."

  source {
    owner             = "AWS"
    source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#iam-user-unused-credentials-check
resource "aws_config_config_rule" "iam-user-unused-credentials-check" {
  name        = "grace-${var.env}-iam-user-unused-credentials-check"
  description = "Checks whether your AWS Identity and Access Management (IAM) users have passwords or active access keys that have not been used within the specified number of days you provided."

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  input_parameters = <<EOF
{

  "maxCredentialUsageAge" : "90"
}
EOF

  depends_on = ["aws_config_configuration_recorder.config"]
}

#root MFA
resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name        = "grace-${var.env}-root-account-mfa-enabled"
  description = "Checks whether users of your AWS account require a multi-factor authentication MFA device to sign in with root credentials.."

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#Access Key Roation
resource "aws_config_config_rule" "access-keys-rotated" {
  name        = "grace-${var.env}-access-keys-rotated"
  description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is non-compliant if the access keys have not been rotated for more than maxAccessKeyAge number of days."

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  input_parameters = <<EOF
{

  "maxAccessKeyAge" : "90"
}
EOF

  depends_on = ["aws_config_configuration_recorder.config"]
}

#cloud_trail_log_file_validation_enabled

resource "aws_config_config_rule" "cloud_trail_log_file_validation_enabled" {
  name        = "grace-${var.env}-cloudtrail-log-file-validation-enabled"
  description = "Checks whether AWS CloudTrail creates a signed digest file with logs. The rule is NON_COMPLIANT if the validation is not enabled."

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#cloud_trail_cloud_watch_logs_enabled

resource "aws_config_config_rule" "cloud_trail_cloud_watch_logs_enabled" {
  name        = "grace-${var.env}-cloudtrail-cloudwatch-logs-enabled"
  description = "Checks whether AWS CloudTrail trails are configured to send logs to Amazon CloudWatch Logs. The trail is NON_COMPLIANT if the CloudWatchLogsLogGroupArn property of the trail is empty."

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#s3_bucket_logging_enabled

resource "aws_config_config_rule" "s3_bucket_logging_enabled" {
  name        = "grace-${var.env}-s3-bucket-logging-enabled"
  description = "Checks whether logging is enabled for your S3 buckets."

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }

  input_parameters = <<EOF
{
  "targetBucket": "${var.access_bucket}"
}
EOF

  depends_on = ["aws_config_configuration_recorder.config"]
}

#iam-root-access-key-check
resource "aws_config_config_rule" "iam-root-access-key-check" {
  name        = "grace-${var.env}-iam-root-access-key-check"
  description = "Checks whether the root user access key is available. The rule is compliant if the user access key does not exist."

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#s3_bucket_public_read_prohibited

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "grace-${var.env}-s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#s3_bucket_public_write_prohibited

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "grace-${var.env}-s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#s3_bucket_server_side_encryption_enabled

resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "grace-${var.env}-s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#s3_bucket_versioning_enabled

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "grace-${var.env}-s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}

#guardduty_enabled_centralized

resource "aws_config_config_rule" "guardduty_enabled_centralized" {
  name = "grace-${var.env}-guardduty-enabled-centralized"

  source {
    owner             = "AWS"
    source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
  }

  depends_on = ["aws_config_configuration_recorder.config"]
}


