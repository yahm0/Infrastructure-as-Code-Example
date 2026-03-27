# --- SNS Topic for Alarm Notifications ---

resource "aws_sns_topic" "alarms" {
  count = var.enable_alarms ? 1 : 0

  name = "${var.alarm_prefix}-alarms"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count = var.enable_alarms && var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# --- EC2 CPU Alarm ---

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count = var.enable_alarms && var.ec2_instance_id != "" ? 1 : 0

  alarm_name          = "${var.alarm_prefix}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  tags = var.tags
}

# --- RDS CPU Alarm ---

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  count = var.enable_alarms && var.rds_instance_id != "" ? 1 : 0

  alarm_name          = "${var.alarm_prefix}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = var.tags
}

# --- RDS Free Storage Alarm ---

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  count = var.enable_alarms && var.rds_instance_id != "" ? 1 : 0

  alarm_name          = "${var.alarm_prefix}-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB in bytes
  alarm_description   = "RDS free storage is below 5 GB"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  tags = var.tags
}

# --- ALB 5xx Errors Alarm ---

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.enable_alarms && var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "${var.alarm_prefix}-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5xx errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alarms[0].arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = var.tags
}
