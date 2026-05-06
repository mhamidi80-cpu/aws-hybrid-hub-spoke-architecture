# Transit Gateway (The Hub)
resource "aws_ec2_transit_gateway" "hub" {
  description                     = "Mohamed Hamidi Consulting - Central Hub"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"

  tags = { Name = "central-tgw-hub" }
}

# Site-to-Site VPN to Paris Data Center
resource "aws_vpn_connection" "onprem_vpn" {
  customer_gateway_id = aws_customer_gateway.paris_dc.id
  transit_gateway_id  = aws_ec2_transit_gateway.hub.id
  type                = "ipsec.1"
  static_routes_only  = false # Enables BGP
}

resource "aws_customer_gateway" "paris_dc" {
  bgp_asn    = 65000
  ip_address = "203.0.113.12" # Representative On-Prem IP
  type       = "ipsec.1"
}
