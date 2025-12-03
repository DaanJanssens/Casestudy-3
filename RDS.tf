resource "aws_db_subnet_group" "db_subnet_group" {
  name = "innovatech-mysql-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_01.id, aws_subnet.db_subnet_02.id]

  tags = {
    Name = "innovatech-mysql-subnet-group"
  }
}

resource "aws_db_instance" "mysql_db" {
  identifier = "hrappdb"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "innovatech_hr"
  username = var.db_user
  password = var.db_password
  publicly_accessible = false
  vpc_security_group_ids = aws_security_group.database_sg.id
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot = true

  tags = {
    Name = "innovatech_hrapp_mysql_db"
  }
}