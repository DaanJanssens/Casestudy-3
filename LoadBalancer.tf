resource "aws_lb" "alb" {
  name               = "innovatech-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.lb_subnet_01.id, aws_subnet.lb_subnet_02.id]
  security_groups    = [aws_security_group.loadbalancer_sg.id]
  idle_timeout       = 60
}

resource "aws_lb_target_group" "tg" {
  name        = "fargate-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.innovatech.id
  target_type = "ip"

  health_check {
    path    = "/"
    matcher = "200-399"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}