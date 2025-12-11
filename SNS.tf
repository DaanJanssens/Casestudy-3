resource "aws_sns_topic" "ecs_alerts" {
  name = "ecs-task-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}