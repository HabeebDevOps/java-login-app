resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = var.vpc1_id
  peer_vpc_id   = var.vpc2_id
  auto_accept   = true
  
  tags = {
    Name = "${var.vpc1_name}-${var.vpc2_name}-peering"
  }
}

resource "aws_route" "vpc1_to_vpc2" {
  route_table_id            = var.vpc1_route_table_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "vpc2_to_vpc1" {
  route_table_id            = var.vpc2_route_table_id
  destination_cidr_block    = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
