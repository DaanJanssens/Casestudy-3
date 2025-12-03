resource "aws_ecs_cluster" "faregate_gluster" {
  name = "faregate-cluster"
}

resource "aws_ecr_repository" "hrapp" {
  name = "hrapp"
}

resource "aws_ecs_task_definition" "hrapp" {

  family                   = "innovatech_hr_app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "hrapp"
      image     = "${aws_ecr_repository.hrapp.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]

      environmet = [
        { name = "DB_USER", value = var.db_user },
        { name = "DB_PASSWORD", value = var.db_password },
        { name = "DB_HOST", value = aws_db_instance.mysql_db.address },
        { name = "DB_NAME", value = "innovatech_hr" }
      ]

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 5
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "hrapp"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "web_service" {
  name            = "innovatech_web_service"
  cluster         = aws_ecs_cluster.faregate_gluster.id
  task_definition = aws_ecs_task_definition.hrapp.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.web_subnet_01.id, aws_subnet.web_subnet_02.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.web_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "hrapp"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.listener]
}