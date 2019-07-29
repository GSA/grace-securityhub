
module "app" {
  source = "./app"
  appenv = "${var.appenv}"
}

module "s3" {
  source                = "./S3"
  env                   = "${module.app.env}"
  name                  = "${module.app.name}"
  aws_account_id        = "${module.app.account_id}"
  master_aws_account_id = "${var.master_aws_account_id}"
  config_kms_key        = "${module.app.config_kms_key}"
  aws_region            = "${var.aws_region}"
  config_bucket         = "grace-${module.app.env}-config"
}

module "cloudwatch" {
  source                       = "./cloudwatch"
  env                          = "${module.app.env}"
  aws_account_id               = "${module.app.account_id}"
  master_aws_account_id        = "${var.master_aws_account_id}"
  aws_region                   = "${var.aws_region}"
  bucket_name                  = "${module.s3.bucket_name}"
  cloudtrail_kms_key           = "${module.s3.cloudtrail_kms_key}"
  cloudwatch_delivery_role_id  = "${module.iam.cloudwatch_delivery_role_id}"
  cloudwatch_delivery_role_arn = "${module.iam.cloudwatch_delivery_role_arn}"
  email_address                = "${var.email_address}"
}

module "config" {
  source         = "./config"
  name           = "${module.s3.bucket_name}"
  env            = "${module.app.env}"
  aws_account_id = "${module.app.account_id}"
  aws_region     = "${var.aws_region}"
  access_bucket  = "grace-${module.app.env}-access-logs"
}


terraform {
  backend "s3" {
    region = "us-east-1"
  }
}

provider "aws" {}
