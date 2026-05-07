output "tgw_id" {
  value = aws_ec2_transit_gateway.hub.id
}

output "vpn_connection_id" {
  value = aws_vpn_connection.onprem_vpn.id
}
