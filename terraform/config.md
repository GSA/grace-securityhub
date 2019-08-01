# GRACE LOGGING - config [![CircleCI](https://circleci.com/gh/GSA/grace-logging.svg?style=svg&circle-token=fe4919d129e0a79d08448086f540b960a845a4b2)](https://circleci.com/gh/GSA/grace-logging)


This module creates the IAM Role and Policy for the AWS Config Service. It also creates and activates the Config Recorder Service. This module also covers several of the AWS CIS Benchmark controls by creating AWS Managed Config Rules. The Config Rules provide compliance status reporting for various resources within the GRACE environments.

![integration](https://github.com/GSA/grace-logging/blob/master/terraform/cloudwatch/res/GRACE%20Logging%20and%20Monitoring%20v4.png)

## Variables

Some variables are required and do not have default values. Those variables must be filled in by you. Otherwise, you can accept the default values if they meet your needs.

| Variable                       | Description               | Required   | Initial value  |
|--------------------------------|---------------------------|------------|----------------|
| env                            | App Environment           | Yes        | sandbox        |
| name                           | App name                  | Yes        |                |
| aws_region                     | AWS Region                | Yes        | us-east-1      |
| aws_config_bucket_key_prefix   | Config recorder bucket prefix | Yes        | awsconfig      |
| aws_account_id                 | AWS Acount Number         | Yes        |                |
| access_bucket                  | Access Logging Bucket Name| Yes        |  grace-${module.app.env}-access-logs   |

## AWS Managed Config Rules

Some AWS Managed Config Rules have parameters that are used for the analysis of specific resource settings.  You can accept the default values of these parameters if they meet your needs or update them according to the specifications of your environment.

AWS Config Rule  | Parameters
------------- | -------------
CLOUD_TRAIL_ENABLED  | 
CLOUDWATCH_ALARM_ACTION_CHECK  | 
IAM_PASSWORD_POLICY  | Policy Settings
CLOUD_TRAIL_ENCRYPTION_ENABLED  | 
MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS  | 
IAM_USER_UNUSED_CREDENTIALS_CHECK  |  maxCredentialUsageAge : 90
ROOT_ACCOUNT_MFA_ENABLED  | 
ACCESS_KEYS_ROTATED  |  maxAccessKeyAge : 90
CLOUD_TRAIL_LOG_FILE_VALIDATION_ENABLED  | 
CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED  | 
S3_BUCKET_LOGGING_ENABLED  | targetBucket : ${var.access_bucket}
IAM_ROOT_ACCESS_KEY_CHECK  | 
S3_BUCKET_PUBLIC_READ_PROHIBITED  | 
S3_BUCKET_PUBLIC_WRITE_PROHIBITED  | 
S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED  | 
S3_BUCKET_VERSIONING_ENABLED  | 
GUARDDUTY_ENABLED_CENTRALIZED  | 




