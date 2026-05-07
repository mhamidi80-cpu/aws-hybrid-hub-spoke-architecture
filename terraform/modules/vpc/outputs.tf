output "inspection_vpc_id" {
  value = aws_vpc.inspection_vpc.id
}

output "hub_transit_subnets" {
  value = [
    aws_subnet.hub_transit_a.id,
    aws_subnet.hub_transit_b.id
  ]
}

output "spoke_a_vpc_id" {
  value = aws_vpc.spoke_a.id
}

output "spoke_a_subnet_id" {
  value = aws_subnet.spoke_a_subnet.id
}

output "spoke_b_vpc_id" {
  value = aws_vpc.spoke_b.id
}

output "spoke_b_subnet_id" {
  value = aws_subnet.spoke_b_subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.hub_public_subnet.id
}
