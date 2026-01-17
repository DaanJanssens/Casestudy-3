#Creates the lambda fucntion for the stopped ECS's
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

#Creates the Event Rule for the stopped ECS's
resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
    name = "ecs-task-stopped-rule"
    description = "Trigger when ECS fargate task stops"

    event_pattern = jsonencode({
        source =["aws.ecs"]
        detail-type = ["ECS Task State Change"]
        detail ={
            lastStatus =["STOPPED", "DEPROVISIONING"]
            clusterArn =[aws_ecs_cluster.faregate_cluster.arn]
        }
    })
  
}

#Assigs the tagt for hte event rule
resource "aws_cloudwatch_event_target" "ecs_to_lambda" {
    rule = aws_cloudwatch_event_rule.ecs_task_stopped.name
    target_id = "ecsTASKStoppedToLambda"
    arn = aws_lambda_function.ecs_task_notify.arn
}

#Allow execurtion of event brige
resource "aws_lambda_permission" "allow_eventbridge" {
    statement_id = "AllowExecutionFromEventBridge"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ecs_task_notify.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ecs_task_stopped.arn
}

#Creates lambda function to stop RDS's
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

#Creates lambda function to start RDS's
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

#Creates event rule to stop the RDS on a schedule
resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "shutdown-env-evening"
  schedule_expression = "cron(0 18 * * ? *)"
}

#Creates event rule to start the RDS on a schedule
resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "start-env-morning"
  schedule_expression = "cron(0 6 * * ? *)"
}

#Assigs a target for the stop event bridge
resource "aws_cloudwatch_event_target" "stop_trigger" {
  rule      = aws_cloudwatch_event_rule.stop_schedule.name
  target_id = "stopLambda"
  arn       = aws_lambda_function.stop_env.arn
}

#Assigs a target for the start event bridge
resource "aws_cloudwatch_event_target" "start_trigger" {
  rule      = aws_cloudwatch_event_rule.start_schedule.name
  target_id = "startLambda"
  arn       = aws_lambda_function.start_env.arn
}

#Allows stop event bridge to trigger
resource "aws_lambda_permission" "allow_stop" {
  statement_id  = "AllowEventStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_env.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}

#Allows start event bridge to trigger
resource "aws_lambda_permission" "allow_start" {
  statement_id  = "AllowEventStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_env.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}