# Setup CloudWatch metrics

resource "aws_cloudwatch_metric_alarm" "hello_world_cpu" {
  alarm_name          = "hello-world-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.hello_world_cl.name
    ServiceName = aws_ecs_service.hello_world_api_service.name
  }

  alarm_description = "This metric monitors ECS service CPU utilization"
  alarm_actions     = []
}

resource "aws_cloudwatch_metric_alarm" "hello_world_memory" {
  alarm_name          = "hello-world-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.hello_world_cl.name
    ServiceName = aws_ecs_service.hello_world_api_service.name
  }

  alarm_description = "This metric monitors ECS service memory utilization"
  alarm_actions     = []
}