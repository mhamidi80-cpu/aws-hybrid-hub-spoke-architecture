output "tgw_id" {
  value = aws_ec2_transit_gateway.hub.id
}

output "spoke_a_vpc_id" {
  value = aws_vpc.spoke_a.id
}

output "spoke_b_vpc_id" {
  value = aws_vpc.spoke_b.id
}

output "spoke_a_web_sg_id" {
  value = aws_security_group.spoke_a_web_sg.id
}

output "spoke_b_dev_sg_id" {
  value = aws_security_group.spoke_b_dev_sg.id
}


output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}


