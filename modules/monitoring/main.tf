resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name = "wp-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  dimensions = { AutoScalingGroupName = var.asg_name }
}

resource "aws_cloudwatch_metric_alarm" "status_check_alarm" {
  alarm_name          = "instance-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Maximum" 
  threshold           = "0"
  alarm_description   = "This metric monitors ec2 instance status checks"

  dimensions = {
    AutoScalingGroupName = var.asg_name 
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connection_alarm" {
  alarm_name          = "DatabaseConnections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Maximum" 
  threshold           = "80"
  alarm_description   = "Numbers of database connections is above 0, which may indicate an issue with the database connectivity or configuration."

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "NetworkIn" {
  alarm_name          = "LowNetworkTraffic"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average" 
  threshold           = "1000"
  alarm_description   = "This metric monitors low traffic"
  dimensions = {
    AutoScalingGroupName = var.asg_name 
  }
}
resource "aws_cloudwatch_dashboard" "d" {
  dashboard_name = "WordPress-Monitor"
  dashboard_body = jsonencode({
    widgets = [
      # Ряд 1: CPU та RDS
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6
        properties = { 
          metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]], 
          region = var.region, title = "EC2 CPU Utilization" 
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6
        properties = { 
          metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_instance_identifier]], 
          region = var.region, title = "RDS Connections" 
        }
      },
      # Ряд 2: Трафік та Статус
      {
        type = "metric", x = 0, y = 6, width = 12, height = 6
        properties = { 
          metrics = [["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.asg_name]], 
          region = var.region, title = "Network In (Bytes)" 
        }
      },
      {
        type = "metric", x = 12, y = 6, width = 12, height = 6
        properties = { 
          metrics = [["AWS/EC2", "StatusCheckFailed", "AutoScalingGroupName", var.asg_name]], 
          region = var.region, title = "Instance Status Checks" 
        }
      }
    ]
  })
}
