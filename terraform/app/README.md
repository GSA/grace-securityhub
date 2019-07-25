# App [![CircleCI](https://circleci.com/gh/GSA/grace-logging.svg?style=svg&circle-token=fe4919d129e0a79d08448086f540b960a845a4b2)](https://circleci.com/gh/GSA/grace-logging)

Used by the root module to interpolate environment variables/create unique variables. Terraform does not support interpolating variables inside of a variable declaration.



## Outputs

| Output                     | Description               |
|--------------------------------|---------------------------|
| env    | application environment         |
| name   | logging bucket name         |
| account_id   | current AWS Account ID         |
| config_kms_key   | KMS Key ARN         |
