
resource "aws_cloudwatch_metric_alarm" "cpu" {
  for_each            = local.dbs
  alarm_name          = "${each.key}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/${each.value.cw_namespace}"
  period              = "120"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This alarm monitors DocDB cpu utilization above expected"
  treat_missing_data  = "ignore"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}


resource "aws_cloudwatch_metric_alarm" "credits" {
  for_each            = local.dbs
  alarm_name          = "${each.key}-cpu-surplus-credits-charged"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUSurplusCreditsCharged"
  namespace           = "AWS/${each.value.cw_namespace}"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors DocDB CPU surplus credits charged"
  treat_missing_data  = "ignore"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}


resource "aws_cloudwatch_metric_alarm" "connections" {
  for_each            = local.dbs
  alarm_name          = "${each.key}-database-connections"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/${each.value.engine}"
  period              = "120"
  statistic           = "Minimum"
  threshold           = each.value.max_connections_threshold
  alarm_description   = "This metric monitors DocDB database connections"
  treat_missing_data  = "ignore"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}
