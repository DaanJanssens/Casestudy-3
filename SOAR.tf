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