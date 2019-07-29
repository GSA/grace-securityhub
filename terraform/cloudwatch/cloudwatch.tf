#Create CT
resource "aws_cloudtrail" "Cloudtrail" {
  name                          = "Cloudtrail"
  s3_bucket_name                = "${var.bucket_name}"
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = "${var.cloudtrail_kms_key}"
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_events.arn}"
  cloud_watch_logs_role_arn     = "${var.cloudwatch_delivery_role_arn}"
}

#AWS Cloud Watch Delivery IAM Policy
resource "aws_iam_role_policy" "cloudwatch_delivery_policy" {
  name = "${var.iam_role_policy_name}"

  role = "${var.cloudwatch_delivery_role_id}"

  policy = <<END_OF_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailCreateLogStream2014110",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_events.name}:log-stream:*"
      ]
    },
    {
      "Sid": "AWSCloudTrailPutLogEvents20141101",
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents"
      ],
      "Resource": [
        "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_events.name}:log-stream:*"
      ]
    }
  ]
}
END_OF_POLICY
}

#Create cloud watch log group
resource "aws_cloudwatch_log_group" "cloudtrail_events" {
  name = "${var.cloudwatch_logs_group_name}"
  retention_in_days = "${var.cloudwatch_logs_retention_in_days}"
}

#Create permission for cross-account event bus access from Master Acct
resource "aws_cloudwatch_event_permission" "DevMasterAccountAccess" {
  principal = "${var.master_aws_account_id}"
  statement_id = "DevMasterAccountAccess"
}

#Metric based alarms

resource "aws_cloudwatch_log_metric_filter" "root_usage" {
  name = "RootUsage"
  pattern = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail_events.name}"

  metric_transformation {
    name = "RootUsage"
    namespace = "${var.alarm_namespace}"
    value = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_usage" {
  alarm_name = "RootUsage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "${aws_cloudwatch_log_metric_filter.root_usage.id}"
  namespace = "${var.alarm_namespace}"
  period = "300"
  statistic = "Sum"
  threshold = "1"
  treat_missing_data = "${var.treat_missing_data}"
  alarm_description = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
  alarm_actions = ["${module.sns.alarm_actions_alarms["Arn"]}"]
}

resource "aws_cloudwatch_log_metric_filter" "console_signin_failures" {
  name = "ConsoleSigninFailures"
  pattern = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail_events.name}"

  metric_transformation {
    name = "ConsoleSigninFailures"
    namespace = "${var.alarm_namespace}"
    value = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_failures" {
  alarm_name = "ConsoleSigninFailures"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "${aws_cloudwatch_log_metric_filter.console_signin_failures.id}"
  namespace = "${var.alarm_namespace}"
  period = "300"
  statistic = "Sum"
  threshold = "5"
  treat_missing_data = "${var.treat_missing_data}"
  alarm_description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
  alarm_actions = ["${module.sns.alarm_actions_alarms["Arn"]}"]
}

resource "aws_cloudwatch_log_metric_filter" "disable_or_delete_cmk" {
  name = "DisableOrDeleteCMK"
  pattern = "{ ($.eventSource = kms.amazonaws.com) && (($.eventName = DisableKey) || ($.eventName = ScheduleKeyDeletion)) }"
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail_events.name}"

  metric_transformation {
    name = "DisableOrDeleteCMK"
    namespace = "${var.alarm_namespace}"
    value = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "disable_or_delete_cmk" {
  alarm_name = "DisableOrDeleteCMK"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "${aws_cloudwatch_log_metric_filter.disable_or_delete_cmk.id}"
  namespace = "${var.alarm_namespace}"
  period = "300"
  statistic = "Sum"
  threshold = "1"
  treat_missing_data = "${var.treat_missing_data}"
  alarm_description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
  alarm_actions = ["${module.sns.alarm_actions_alarms["Arn"]}"]
}

resource "aws_cloudwatch_log_metric_filter" "console_sign_in_without_mfa" {
  name = "ConsoleSignInWithoutMfa"
  pattern = "{ ($.eventName = ConsoleLogin) && ($.additionalEventData.MFAUsed = No) }"
  log_group_name = "${aws_cloudwatch_log_group.cloudtrail_events.name}"

  metric_transformation {
    name = "ConsoleSignInWithoutMfa"
    namespace = "${var.alarm_namespace}"
    value = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_sign_in_without_mfa" {
  alarm_name = "ConsoleSignInWithoutMfa"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "${aws_cloudwatch_log_metric_filter.console_sign_in_without_mfa.id}"
  namespace = "${var.alarm_namespace}"
  period = "300"
  statistic = "Sum"
  threshold = "1"
  treat_missing_data = "${var.treat_missing_data}"
  alarm_description = "Monitoring for console logins without MFA will provide visibility into all console logins that do not utilize MFA."
  alarm_actions = ["${module.sns.alarm_actions_alarms["Arn"]}"]
}

resource "aws_cloudwatch_event_rule" "SCP" {
  name = "grace-${var.env}-capture-aws-SCP-Modification"
  description = "Capture each AWS SCP Modficiation"

  event_pattern = <<PATTERN
  {
  "source": [
    "aws.organizations"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "organizations.amazonaws.com"
    ],
    "eventName": [
      "AttchPolicy",
      "DetachPolicy",
      "UpdatePolicy",
      "DisablePolicyType",
      "EnablePolicyType"
    ]
  }
}
PATTERN
}

 resource "aws_cloudwatch_event_target" "sns_scp" {
  rule      = "${aws_cloudwatch_event_rule.SCP.name}"
  target_id = "CloudWatch-Event-SCP"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "AccountID"       = "$.detail.userIdentity.accountId"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

     input_template = <<INPUT_TEMPLATE_EOF
    {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "User ID": <UserID>,
       "Account ID": <AccountID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
  }
    INPUT_TEMPLATE_EOF
  }
}
   
resource "aws_cloudwatch_event_rule" "S3" {
  name = "grace-${var.env}-capture-aws-S3-Modification"
  description = "Capture each AWS S3 Modficiation"

  event_pattern = <<PATTERN
{
  "detail": {
    "eventName": [
      "PutBucketAcl",
      "PutBucketPolicy",
      "PutBucketCors",
      "PutBucketLifecycle",
      "PutBucketReplication",
      "DeleteBucketPolicy",
      "DeleteBucketCors",
      "DeleteBucketLifecycle",
      "DeleteBucketReplication"
    ],
    "eventSource": [
      "s3.amazonaws.com"
    ]
  },
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.s3"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_s3" {
  rule      = "${aws_cloudwatch_event_rule.S3.name}"
  target_id = "CloudWatch-Event-S3"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "AccountID"       = "$.detail.userIdentity.accountId"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF
    {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "User ID": <UserID>,
       "Account ID": <AccountID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
}
    INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "awsconfig" {
  name = "grace-${var.env}-capture-aws-config-compliance-state-changes"
  description = "Capture changes to AWS Config Rule compliance states"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.config"
  ],
  "detail-type": [
    "Config Rules Compliance Change"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_awsconfig" {
  rule      = "${aws_cloudwatch_event_rule.awsconfig.name}"
  target_id = "CloudWatch-Event-awsconfig"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"           = "$.time"
      "EventType"           = "$.detail-type"
      "AWSRegion"           = "$.detail.awsRegion"
      "AWSAccount"          = "$.detail.awsAccountId"
      "ConfigRuleName"      = "$.detail.newEvaluationResult.evaluationResultIdentifier.evaluationResultQualifier.configRuleName"
      "ResourceType"        = "$.detail.newEvaluationResult.evaluationResultIdentifier.evaluationResultQualifier.resourceType"
      "ResourceID"          = "$.detail.newEvaluationResult.evaluationResultIdentifier.evaluationResultQualifier.resourceId"
      "NewComplianceStatus" = "$.detail.newEvaluationResult.complianceType"
      "OldComplianceStatus" = "$.detail.oldEvaluationResult.complianceType"
    }

    input_template = <<INPUT_TEMPLATE_EOF
  {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "AWS Region": <AWSRegion>,
       "AWS Account": <AWSAccount>,
       "Config Rule": <ConfigRuleName>,
       "Resource Type": <ResourceType>,
       "Resource ID": <ResourceID>,
       "New Compliance State": <NewComplianceStatus>,
       "Old Compliance State": <OldComplianceStatus>
}
    INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "ec2_changes" {
  name = "grace-${var.env}-capture-aws-ec2-modifications"
  description = "Capture each AWS ec2 Modficiation"

  event_pattern = <<PATTERN
{
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ]
  },
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.ec2"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_ec2" {
  rule      = "${aws_cloudwatch_event_rule.ec2_changes.name}"
  target_id = "CloudWatch-Event-ec2-changes"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "AccountID"       = "$.detail.userIdentity.accountId"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF
 {
       "Event Time": <EventTime>,
       "Event Type": <EventType>,
       "User ID": <UserID>,
       "Account ID": <AccountID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
}
    INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "cloudtrail_configuration_changes" {
  name = "grace-${var.env}-capture-aws-cloudtrail-modification"
  description = "Capture changes to CloudTrail Logging Configuration"

  event_pattern = <<PATTERN
{
  "detail": {
    "eventName": [
      "StopLogging",
      "StartLogging",
      "UpdateTrail",
      "DeleteTrail",
      "CreateTrail",
      "RemoveTags",
      "AddTags",
      "PutEventSelectors"
    ],
    "eventSource": [
      "cloudtrail.amazonaws.com"
    ]
  },
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.cloudtrail"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_cloudtrail_configuration_changes" {
  rule      = "${aws_cloudwatch_event_rule.cloudtrail_configuration_changes.name}"
  target_id = "CloudWatch-Event-cloudtrail_configuration_changes"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF
 {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "User ID": <UserID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
}
   INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "network_gateway_changes" {
  name = "grace-${var.env}-capture-aws-network-gateway-modification"
  description = "Capture each modification event for Customer and Internet Gateways"

  event_pattern = <<PATTERN
{
  "detail": {
    "eventName": [
      "CreateCustomerGateway",
      "DeleteCustomerGateway",
      "AttachInternetGateway",
      "CreateInternetGateway",
      "DeleteInternetGateway",
      "DetachInternetGateway"
    ],
    "eventSource": [
      "cloudtrail.amazonaws.com"
    ]
  },
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.cloudtrail"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_network_gateway_changes" {
  rule      = "${aws_cloudwatch_event_rule.network_gateway_changes.name}"
  target_id = "CloudWatch-Event-network_gateway_changes"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "AccountID"       = "$.detail.userIdentity.accountId"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF
 {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "User ID": <UserID>,
       "Account ID": <AccountID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
}

   INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "config_configuration_changes" {
  name = "grace-${var.env}-capture-aws-config-configuration-modification"
  description = "Capture changes to AWS Config service configuration "

  event_pattern = <<PATTERN
{
  "source": [
    "aws.config"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "config.amazonaws.com"
    ],
    "eventName": [
      "DeleteDeliveryChannel",
      "DeleteConfigurationRecorder",
      "StopConfigurationRecorder",
      "DeleteConfigRule",
      "DeleteEvaluationResults",
      "DeletePendingAggregationRequest",
      "DeleteAggregationAuthorization",
      "DeleteConfigurationAggregator"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_config_configuration_changes" {
  rule      = "${aws_cloudwatch_event_rule.config_configuration_changes.name}"
  target_id = "CloudWatch-Event-config_configuration_changes"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "AccountID"       = "$.detail.userIdentity.accountId"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF

   {
       "Event Time": <EventTime>,
       "Event Type":<EventType>,
       "User ID": <UserID>,
       "Account ID": <AccountID>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Event Source": <EventSource>,
       "AWS Region": <AWSRegion>,
       "Event Name": <EventName>,
       "Event Parameters": <EventParameters>
}



   INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "iam_configuration_changes" {
  name = "grace-${var.env}-capture-aws-iam-configuration-modification"
  description = "Capture changes to AWS IAM configuration "

  event_pattern = <<PATTERN

{
 "source": [
   "aws.iam"
 ],
 "detail-type": [
   "AWS API Call via CloudTrail"
 ],
 "detail": {
   "eventSource": [
     "iam.amazonaws.com"
   ],
   "eventName": [
     "AddUserToGroup",
     "AttachGroupPolicy",
     "AttachRolePolicy",
     "AttachUserPolicy",
     "CreateAccessKey",
     "CreateAccountAlias",
     "CreateGroup",
     "CreateLoginProfile",
     "CreatePolicy",
     "CreateRole",
     "CreateServiceLinkedRole",
     "CreateUser",
     "CreateVirtualMFADevice",
     "DeactivateMFADevice",
     "DeleteAccessKey",
     "DeleteAccountAlias",
     "DeleteAccountPasswordPolicy",
     "DeleteGroup",
     "DeleteGroupPolicy",
     "DeleteLoginProfile",
     "DeletePolicy",
     "DeleteRole",
     "DeleteRolePolicy",
     "DeleteSSHPublicKey",
     "DeleteServiceLinkedRole",
     "DeleteUser",
     "DeleteUserPermissionsBoundary",
     "DeleteUserPolicy",
     "DeleteVirtualMFADevice",
     "DetachGroupPolicy",
     "DetachRolePolicy",
     "DetachUserPolicy",
     "PutGroupPolicy",
     "PutRolePolicy",
     "PutUserPolicy",
     "RemoveUserFromGroup",
     "UpdateAccessKey",
     "UpdateAccountPasswordPolicy",
     "UpdateAssumeRolePolicy",
     "UpdateUser"
   ]
 }
}

PATTERN
}

resource "aws_cloudwatch_event_target" "sns_iam_configuration_changes" {
  rule      = "${aws_cloudwatch_event_rule.iam_configuration_changes.name}"
  target_id = "CloudWatch-Event-iam_configuration_changes"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "UserARN"     = "$.detail.userIdentity.arn"
      "EventSource" = "$.detail.eventSource"
      "AccountID"   = "$.detail.userIdentity.accountId"
      "SourceIP"    = "$.detail.sourceIPAddress"
      "EventType"   = "$.detail.eventType"
      "EventTime"   = "$.detail.eventTime"
      "UserAgent"   = "$.detail.userAgent"
      "AWSRegion"   = "$.detail.awsRegion"
      "EventName"   = "$.detail.eventName"
      "Elements"    = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF

 {
       "Event Time": <EventTime>,
       "User ARN":<UserARN>,
       "Account ID": <AccountID>,
       "Event Source": <EventSource>,
       "Event Type": <EventType>,
       "Event Name": <EventName>,
       "AWS Region": <AWSRegion>,
       "Source IP": <SourceIP>,
       "User Agent": <UserAgent>,
       "Elements": <Elements>
}


   INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name = "grace-${var.env}-capture-aws-guardduty-findings"
  description = "Capture findings provided by GuardDuty"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_guardduty_findings" {
  rule      = "${aws_cloudwatch_event_rule.guardduty_findings.name}"
  target_id = "CloudWatch-Event-guardduty_findings"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"   = "$.time"
      "EventType"   = "$.detail-type"
      "EventSource" = "$.source"
      "AccountID"   = "$.account"
      "AWSRegion"   = "$.region"
      "Severity"    = "$.detail.severity"
      "Title"       = "$.detail.title"
      "Description" = "$.detail.description"
      "Finding"     = "$.detail"
    }

    input_template = <<INPUT_TEMPLATE_EOF
 {
		"Event Time": <EventTime>,
		"Event Type": <EventType>,
		"Event Source": <EventSource>,
		"Account ID": <AccountID>,
		"AWS Region": <AWSRegion>,
		"Event Severity": <Severity>,
		"Title": <Title>,
		"Description": <Description>,
		"Finding": <Finding>
}
    INPUT_TEMPLATE_EOF
  }
}

resource "aws_cloudwatch_event_rule" "assume_fullAdmin_event" {
  name = "grace-${var.env}-capture-aws-assume-fullAdmin"
  description = "Capture events matching AssumeRole for fullAdmin and orgAdmin"

  event_pattern = <<PATTERN
{
"source":[
"aws.sts"
],
"detail-type":[
"AWS API Call via CloudTrail"
],
"detail":{
"eventSource":[
"sts.amazonaws.com"
],
"eventName":[
"AssumeRole"
],
"requestParameters":{
"roleArn":[
"arn:aws:iam::*:role/grace-${var.env}-management-orgAdmin",
"arn:aws:iam::${var.aws_account_id}:role/grace-${var.env}-management-fullAdmin"
]
}
}
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns_assume_fullAdmin" {
  rule      = "${aws_cloudwatch_event_rule.assume_fullAdmin_event.name}"
  target_id = "CloudWatch-Event-Assume-fullAdmin"
  arn       = "${module.sns.alarm_actions["ARN"]}"

  input_transformer = {
    input_paths = {
      "EventTime"       = "$.detail.eventTime"
      "EventType"       = "$.detail-type"
      "UserID"          = "$.detail.userIdentity.arn"
      "SourceIP"        = "$.detail.sourceIPAddress"
      "UserAgent"       = "$.detail.userAgent"
      "EventSource"     = "$.detail.eventSource"
      "AWSRegion"       = "$.detail.awsRegion"
      "EventName"       = "$.detail.eventName"
      "EventParameters" = "$.detail.requestParameters[*]"
    }

    input_template = <<INPUT_TEMPLATE_EOF
{
"Event Time": <EventTime>,
"Event Type":<EventType>,
"User ID": <UserID>,
"Source IP": <SourceIP>,
"User Agent": <UserAgent>,
"Event Source": <EventSource>,
"AWS Region": <AWSRegion>,
"Event Name": <EventName>,
"Event Parameters": <EventParameters>
}
INPUT_TEMPLATE_EOF
  }
}

