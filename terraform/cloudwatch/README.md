# GRACE LOGGING - cloudwatch [![CircleCI](https://circleci.com/gh/GSA/grace-logging.svg?style=svg&circle-token=fe4919d129e0a79d08448086f540b960a845a4b2)](https://circleci.com/gh/GSA/grace-logging)

## Overview

The CloudWatch module creates the basic infrastructure setup for the activation of a multi-region CloudTrail Trail, a CloudWatch Log Group, and the required IAM Policy permissions for delivery of logs.  The CloudWatch module also creates 5 metric based Alarms and 9 Event Rules.  The Alarms and Event Rules have been designed in accordance with suggestions provided by the CIS Benchmark for AWS.  The module utilizes a CloudFormation stack to create the SNS Topics used for the delivery of email notifications for monitoring. The diagram below shows how the use of CloudTrail, CloudWatch, and the SNS notifcations are integrated in the GRACE-LOGGING solution.

![integration](https://github.com/GSA/grace-logging/blob/master/terraform/cloudwatch/res/GRACE%20Logging%20and%20Monitoring%20-%20CloudWatch.png)

## Repository contents
- Terraform file required to build AWS Resources for CloudTrail and CloudWatch services (cloudwatch.tf)
- Cloudformation template used for building the SNS email stack, and the Terraform wrapper to launch it (SNS directory)

## Variables

Some variables are required and do not have default values. Those variables must be filled in by you. Otherwise, you can accept the default values if they meet your needs.

| Variable                       | Description                  | Required   | Initial value  |
|--------------------------------|------------------------------|------------|----------------|
| env                            | Environment Prod or Dev      | Yes        |  sandbox       |
| aws_account_id                 | AWS Acount Number            | Yes        |                |
| master_aws_account_id          | AWS Master Account Number    | Yes        |                |
| aws_region                     | AWS Region                   | Yes        |  us-east-1     |
| bucket_name                    | Logging Bucket Name          | Yes        |                |
| cloudtrail_kms_key             | KMS Key ID for CT Encryption | Yes        |                |
| cloudwatch_delivery_role_id    | IAM Role ID for CW           | Yes        |                |
| cloudwatch_delivery_role_arn   | IAM Role ARN for CW          | Yes        |                |
| email_address                  | Notification EMAIL for SNS   | Yes        |                |
| access_bucket                  | Access Logging Bucket Name   | Yes        |  grace-${module.app.env}-access-logs   |
| config_bucket                  | tf State Bucket Name         | Yes        |  grace-${module.app.env}-config        |

## Outputs

| Output                     | Description               |
|--------------------------------|---------------------------|
| alarm_actions    | SNS Topic for CW Event Rules         |
| alarm_actions_alarms   | SNS Topic for CW Alarms         |
