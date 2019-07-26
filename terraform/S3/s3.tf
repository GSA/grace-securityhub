#Create Bucket

resource "aws_s3_bucket" "grace-logging" {
  bucket = "${var.name}"
  acl    = "${var.acl}"

  depends_on = ["aws_s3_bucket_policy.grace-logging"]

  logging {
    target_bucket = "arn:aws:s3:::${aws_s3_bucket.grace-access-logs.bucket}"
    target_prefix = "${var.name}-logs/"
  }

  versioning {
    enabled = "${var.enable_versioning}"
  }

  tags = "${var.tags}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.cloudtrail.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "awslog"
    enabled = true

    prefix = "${var.lifecycle_prefix}"

    tags {
      rule      = "awslog"
      autoclean = "true"
    }

    transition {
      days          = "${var.glacier_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = 900
    }
  }
}

#public access block for grace-logging
resource "aws_s3_bucket_public_access_block" "grace-logging" {
  bucket = "${aws_s3_bucket.grace-logging.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#bucket policy
resource "aws_s3_bucket_policy" "grace-logging" {
  bucket = "${var.name}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "config.amazonaws.com",
                    "cloudtrail.amazonaws.com"
                ]
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/*"
        },
        {
            "Sid": "AWSLogDeliveryWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "config.amazonaws.com",
                    "cloudtrail.amazonaws.com"
                ]
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/flowlogs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AWSCloudTrailWrite20150319",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/cloudtrail/*"
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.name}"
        },
        {
            "Sid": "AWSLogDeliveryAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "config.amazonaws.com",
                    "cloudtrail.amazonaws.com",
                    "delivery.logs.amazonaws.com"
                ]
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.name}"
        },
        {
            "Sid": "SecOpsAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.name}",
                "arn:aws:s3:::${var.name}/*"
            ]
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/*",
            "Condition": {
                "StringNotEquals": {
                    "s3:x-amz-server-side-encryption": [
                        "AES256",
                        "aws:kms"
                    ]
                }
            }
        },
        {
            "Sid": "DenyUnEncryptedObjectUploads",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.name}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
POLICY
}

# Create new S3 bucket for access logs 

resource "aws_s3_bucket" "grace-access-logs" {
  bucket = "grace-${var.env}-access-logs"
  acl    = "${var.acl}"

  versioning {
    enabled = "${var.enable_versioning}"
  }

  tags = "${var.tags}"

  lifecycle_rule {
    id      = "awslog"
    enabled = true

    prefix = "${var.lifecycle_prefix}"

    tags {
      rule      = "awslog"
      autoclean = "true"
    }

    transition {
      days          = "${var.glacier_days}"
      storage_class = "GLACIER"
    }

    expiration {
      days = 900
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#public access block for grace-access
resource "aws_s3_bucket_public_access_block" "grace-access-logs" {
  bucket = "${aws_s3_bucket.grace-access-logs.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create new S3 bucket for config logs

resource "aws_s3_bucket" "grace-config" {
  bucket = "${var.config_bucket}"
  acl    = "${var.acl}"

  logging {
    target_bucket = "arn:aws:s3:::${aws_s3_bucket.grace-access-logs.bucket}"
    target_prefix = "${var.config_bucket}-logs/"
  }

  versioning {
    enabled = "${var.enable_versioning}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.config_kms_key}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

#public access block for grace-config
resource "aws_s3_bucket_public_access_block" "grace-config" {
  bucket = "${aws_s3_bucket.grace-config.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#create KMS key

resource "aws_kms_key" "cloudtrail" {
  description             = "A KMS key to encrypt CloudTrail events."
  deletion_window_in_days = "${var.key_deletion_window_in_days}"
  enable_key_rotation     = "true"

  policy = <<END_OF_POLICY
{
    "Version": "2012-10-17",
    "Id": "Key policy created by CloudTrail",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::${var.aws_account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {
              "StringLike": {
                "kms:EncryptionContext:aws:cloudtrail:arn":[
       	 	      "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*",
        		    "arn:aws:cloudtrail:*:${var.master_aws_account_id}:trail/*"
      			  ]}
            }
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${var.aws_account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"}
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {"StringEquals": {
                "kms:ViaService": "ec2.${var.aws_region}.amazonaws.com",
                "kms:CallerAccount": "${var.aws_account_id}"
            }}
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${var.aws_account_id}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${var.aws_account_id}:trail/*"}
            }
        }
    ]
}
END_OF_POLICY
}
