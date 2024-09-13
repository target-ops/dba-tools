
resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each            = local.dbs
  alarm_name          = "${each.key}-cpu-utilization"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = "5"
  alarm_description   = "${each.value.cw_namespace} DB CPU utilization is above expected threshold.  Consider increase of DB instance size ${each.value.alarm_mitigation_description}"
  treat_missing_data  = "ignore"
  alarm_actions       = [module.lambda_function.lambda_function_arn]
  ok_actions          = [module.lambda_function.lambda_function_arn]
  datapoints_to_alarm = 5
  threshold_metric_id = "ad1"
  metric_query {
    id          = "m1"
    return_data = true
    period      = 0
    metric {
      dimensions = {
        "DBInstanceIdentifier" = each.key
      }
      metric_name = "CPUUtilization"
      namespace   = "AWS/${each.value.cw_namespace}"
      period      = 300
      stat        = "Average"
    }
  }
  metric_query {
    expression  = "ANOMALY_DETECTION_BAND(m1, 4)"
    id          = "ad1"
    label       = "CPUUtilization (expected)"
    period      = 0
    return_data = true
  }
}


resource "aws_cloudwatch_metric_alarm" "connections" {
  for_each            = local.dbs
  alarm_name          = "${each.key}-database-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "10"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/${each.value.cw_namespace}"
  period              = "60"
  statistic           = "Average"
  threshold           = each.value.max_connections_threshold
  alarm_description   = "${each.value.cw_namespace} DB connections num is above expected limit. Consider increase of DB instance size ${each.value.alarm_mitigation_description}"
  alarm_actions       = [module.lambda_function.lambda_function_arn]
  ok_actions          = [module.lambda_function.lambda_function_arn]
  treat_missing_data  = "ignore"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}
