#Public route table for the Loadbalancer
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.innovatech.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "public_rt"
  }
}

#Connect the Route to the Load balancer subnet 1
resource "aws_route_table_association" "lb_subnet_01_assoc" {
  subnet_id      = aws_subnet.lb_subnet_01.id
  route_table_id = aws_route_table.public_rt.id
}

#Connect the Route to the Load balancer subnet 2
resource "aws_route_table_association" "lb_subent_02_assoc" {
  subnet_id      = aws_subnet.lb_subnet_02.id
  route_table_id = aws_route_table.public_rt.id
}

#Private route table for the web subnets
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.innovatech.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-rt"
  }
}

#Connect the Route to the web subnet1
resource "aws_route_table_association" "web_subnet_01_assoc" {
  subnet_id      = aws_subnet.web_subnet_01.id
  route_table_id = aws_route_table.private_rt.id
}

#Connect the Route to the web subnet1
resource "aws_route_table_association" "web_subnet_02_assoc" {
  subnet_id      = aws_subnet.web_subnet_02.id
  route_table_id = aws_route_table.private_rt.id
}