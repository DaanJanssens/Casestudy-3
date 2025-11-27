resource "aws_ecs_cluster" "faregate_gluster" {
  name = "faregate-cluster"
}

resource "aws_ecs_task_definition" "hr_app" {

  family                   = "innovatech_hr_app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "webapp"
      image     = "nginx:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "webapp"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "web_service" {
  name            = "innovatech_web_service"
  cluster         = aws_ecs_cluster.faregate_gluster.id
  task_definition = aws_ecs_task_definition.hr_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.web_subnet_01.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.web_sg.id]
  }
}