resource "aws_lambda_function" "lambda_function" {
  filename         = var.source_file
  function_name    = local.app_name
  description      = "Creates and connects SecurityHub members from new AWS Org accounts "
  role             = aws_iam_role.iam_role.arn
  handler          = "lambda_handler"
  source_code_hash = filebase64sha256(var.source_file)
  runtime          = "python3.7"
  timeout          = 900

  environment {
    variables = {
      mgmt_account_id   = var.mgmt_account_id
      master_role_name  = var.master_role_name
      organizational_ou = var.organizational_ou
      master_account_id = var.master_account_id
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cwe_rule.arn
}
