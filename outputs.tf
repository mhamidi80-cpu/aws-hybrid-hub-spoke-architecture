output "tgw_id" {
  value = aws_ec2_transit_gateway.hub.id
}

output "spoke_a_vpc_id" {
  value = aws_vpc.spoke_a.id
}

output "spoke_b_vpc_id" {
  value = aws_vpc.spoke_b.id
}
