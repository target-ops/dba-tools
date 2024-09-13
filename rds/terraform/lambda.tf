module "lambda_function" {
  # CW Metric Alarm -> Lambda -> Slack workflow "RDS Alarms" webhook -> #rds-alarms Slack channel
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.8.1"

  function_name = "CW_alarm_handler"
  description   = "Cloudwatch Alarm handler"
  handler       = "parse_alarm.lambda_handler"
  runtime       = "python3.12"

  cloudwatch_logs_retention_in_days = 3
  logging_log_group                 = "/aws/lambda/CW_alarm_handler"

  # when src path is passed to source_path as string pip install will be executed on requirements.txt
  source_path = "lambda_handler"

  environment_variables = {
    WEBHOOK = aws_secretsmanager_secret_version.version.secret_string
  }

  tags = {
    owner = var.team
    environment : var.environment
    provisoned-by : "terraform"
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
}

resource "aws_secretsmanager_secret" "webhook" {
  name = "alarms-slack-webhook"
}

resource "aws_secretsmanager_secret_version" "version" {
  secret_id     = aws_secretsmanager_secret.webhook.id
  secret_string = var.slack_webhook
  lifecycle {
    ignore_changes = [secret_string]
  }
}
