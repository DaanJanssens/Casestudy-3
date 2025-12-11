resource "aws_lambda_function" "ecs_task_notify" {
    function_name = "ecs-task-stopped-sns-notify"
    handler = "lambda_notify.handler"
    role = aws_iam_role.lambda_role.arn
    runtime = "python3.12"
    filename = data.archive_file.lambda_zip.output_path

    environment {
      variables = {
        SNS_TOPIC_ARN = aws_sns_topic.ecs_alerts.arn
      }
    }
  
}

resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
    name = "ecs-task-stopped-rule"
    description = "Trigger when ECS fargate task stops"

    event_pattern = jsonencode({
        source =["aws.ecs"]
        detail-type = ["ECS tTask State Change"]
        detail ={
            lastStatus =["STOPPED", "DEPROVISIONING"]
            clusterArn =[aws_ecs_cluster.faregate_cluster.arn]
        }
    })
  
}

resource "aws_cloudwatch_event_target" "ecs_to_lambda" {
    rule = aws_cloudwatch_event_rule.ecs_task_stopped.name
    target_id = "ecsTASKStoppedToLambda"
    arn = aws_lambda_function.ecs_task_notify.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
    statement_id = "AllowExecutionFromEventBridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ecs_task_notify.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ecs_task_stopped.arn
}

resource "aws_lambda_function" "stop_env" {
    function_name = "auto-shutdown-env"
    handler = "lambda_stop.handler"
    runtime = "python3.12"
    role = aws_iam_role.lambda_auto_ops_role.arn
    filename = data.archive_file.stop_env_zip.output_path

    environment {
      variables = {
        ECS_CLUSTER = var.ecs_cluster_name
        ECS_SERVICES = join(",", var.fargate_services)
        RDS_INSTANCES =join(",", var.rds)
      }
    }
}

resource "aws_lambda_function" "start_env" {
  function_name = "auto-start-env"
  handler       = "lambda_start.handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_auto_ops_role.arn
  filename      = data.archive_file.start_env_zip.output_path

  environment {
    variables = {
      ECS_CLUSTER   = var.ecs_cluster_name
      ECS_SERVICES  = join(",", var.fargate_services)
      RDS_INSTANCES = join(",", var.rds)
      DESIRED_COUNT = tostring(var.desired_day_count)
    }
  }
}

resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "shutdown-env-evening"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "start-env-morning"
  schedule_expression = "cron(0 6 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop_trigger" {
  rule      = aws_cloudwatch_event_rule.stop_schedule.name
  target_id = "stopLambda"
  arn       = aws_lambda_function.stop_env.arn
}

resource "aws_cloudwatch_event_target" "start_trigger" {
  rule      = aws_cloudwatch_event_rule.start_schedule.name
  target_id = "startLambda"
  arn       = aws_lambda_function.start_env.arn
}

resource "aws_lambda_permission" "allow_stop" {
  statement_id  = "AllowEventStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_env.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}

resource "aws_lambda_permission" "allow_start" {
  statement_id  = "AllowEventStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_env.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}