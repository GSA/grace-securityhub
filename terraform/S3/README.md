# GRACE LOGGING - S3 [![CircleCI](https://circleci.com/gh/GSA/grace-logging.svg?style=svg&circle-token=fe4919d129e0a79d08448086f540b960a845a4b2)](https://circleci.com/gh/GSA/grace-logging)

The S3 module creates the bucket resources required for the secure storage of CloudTrail Logs and AWS Config Snapshots. This module also creates the bucket resource required for the storage of S3 access logs.  Versioning and logging are activated for both S3 buckets.

## Variables

Some variables are required and do not have default values. Those variables must be filled in by you. Otherwise, you can accept the default values if they meet your needs.

| Variable                       | Description               | Required   | Initial value  |
|--------------------------------|---------------------------|------------|----------------|
| env                            | Environment Prod or Dev   | Yes        | sandbox        |
| name                           | Logging Bucket Name       | Yes        |                |
| aws_account_id                 | AWS Acount Number         | Yes        |                |
| master_aws_account_id          | AWS Master Account Number | Yes        |                |
| config_kms_key                 | KMS Key ID                | Yes        |                |
| acl                            | Bucket ACL                | Yes        |  log-delivery-write    |
| enable_versioning              | Enable bucket versioning  | Yes        |  true    |
| glacier_days                   | Days to move to Amazon Glacier  | Yes        |  365    |
| lifecycle_prefix               | Prefix for bucket versioning  | Yes        |  awslog/    |
| aws_config_bucket_key_prefix   | Prefix for config snapshot  | Yes        |  awsconfig    |
| aws_region                     | AWS Region                | Yes        |  us-east-1     |
| access_bucket                  | Access Logging Bucket Name| Yes        |  grace-${module.app.env}-access-logs   |
| config_bucket                  | tf State Bucket Name      | Yes        |  grace-${module.app.env}-config        |

## Outputs

| Output                     | Description               |
|--------------------------------|---------------------------|
| cloudtrail_kms_key    | KMS Key ARN          |
| bucket_name   | Logging Bucket Name          |
