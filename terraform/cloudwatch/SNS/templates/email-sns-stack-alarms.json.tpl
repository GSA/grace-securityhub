{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Resources": {
        "EmailSNSTopic": {
            "Type": "AWS::SNS::Topic",
            "Properties": {
                "DisplayName": "${display_name}",
                "Subscription": [
                    {
                        "Endpoint": "${email_address}",
                        "Protocol": "${protocol}"
                    }
                ]
            }
        },
        "EmailSNSTopicPolicy": {
            "Type": "AWS::SNS::TopicPolicy",
            "Properties": {
                "Topics": [
                    {
                        "Ref": "EmailSNSTopic"
                    }
                ],
                "PolicyDocument": {
                    "Version": "2012-10-17",
                    "Id": "__default_policy_ID",
                    "Statement": [
                        {
                            "Sid": "__default_statement_ID",
                            "Effect": "Allow",
                            "Principal": "*",
                            "Action": [
                                "SNS:GetTopicAttributes",
                                "SNS:SetTopicAttributes",
                                "SNS:AddPermission",
                                "SNS:RemovePermission",
                                "SNS:DeleteTopic",
                                "SNS:Subscribe",
                                "SNS:ListSubscriptionsByTopic",
                                "SNS:Publish",
                                "SNS:Receive"
                            ],
                            "Resource": {
                                "Ref": "EmailSNSTopic"
                            },
                            "Condition": {
                                "StringEquals": {
                                    "AWS:SourceOwner": {
                                        "Ref": "AWS::AccountId"
                                    }
                                }
                            }
                        }
                    ]
                }
            }
        }
    },
    "Outputs": {
        "Arn": {
            "Description": "Email SNS Topic ARN",
            "Value": {
                "Ref": "EmailSNSTopic"
            }
        }
    }
}