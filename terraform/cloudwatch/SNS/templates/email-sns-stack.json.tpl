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
                                "sns:GetTopicAttributes",
                                "sns:SetTopicAttributes",
                                "sns:AddPermission",
                                "sns:RemovePermission",
                                "sns:DeleteTopic",
                                "sns:Subscribe",
                                "sns:ListSubscriptionsByTopic",
                                "sns:Publish",
                                "sns:Receive"
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
                        },
                        {  
                          "Sid":"AWSEvents_grace",
                          "Effect":"Allow",
                          "Principal":{  
                          "Service":"events.amazonaws.com"
                        },
                          "Action":"sns:Publish",
                          "Resource":{  
                          "Ref":"EmailSNSTopic"
                          }
                       }
                    ]
                }
            }
        }
    },
    "Outputs": {
        "ARN": {
            "Description": "Email SNS Topic ARN",
            "Value": {
                "Ref": "EmailSNSTopic"
            }
        }
    }
}
