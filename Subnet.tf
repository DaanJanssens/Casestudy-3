resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "allow ssh connection"
  vpc_id      = aws_vpc.innovatech.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow_SSH"
  }
}

resource "aws_security_group" "loadbalancer_sg" {
  name        = "loadbalancer_sg"
  description = "Allow incomming traffic to the loadbalancer"
  vpc_id      = aws_vpc.innovatech.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "loadbalancer_sg"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and HTTPS traffic form the loadbalancer to the webservers"
  vpc_id      = aws_vpc.innovatech.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }



  tags = {
    Name = "web_sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow traffic from webservers to database"
  vpc_id      = aws_vpc.innovatech.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["192.168.3.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.3.0/24"]
  }

  tags = {
    Name = "database_sg"
  }
}
