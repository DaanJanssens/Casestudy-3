resource "aws_nat_gateway" "nat_gw" {
  subnet_id = aws_subnet.lb_subnet_01.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    Name ="nat_gw"
  }
}