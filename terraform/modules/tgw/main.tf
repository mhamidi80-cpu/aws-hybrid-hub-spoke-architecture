resource "aws_ec2_transit_gateway" "hub" {
  description                     = "Mohamed Hamidi Consulting - Central Hub"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"

  tags = {
    Name = "central-tgw-hub"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_attach" {
  subnet_ids             = var.hub_transit_subnets
  transit_gateway_id     = aws_ec2_transit_gateway.hub.id
  vpc_id                 = var.inspection_vpc_id
  appliance_mode_support = "enable"

  tags = {
    Name = "TGW-Attach-Hub-Inspection"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a_attach" {
  subnet_ids         = [var.spoke_a_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = var.spoke_a_vpc_id

  tags = {
    Name = "TGW-Attach-Spoke-A"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b_attach" {
  subnet_ids         = [var.spoke_b_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = var.spoke_b_vpc_id

  tags = {
    Name = "TGW-Attach-Spoke-B"
  }
}

resource "aws_customer_gateway" "paris_dc" {
  bgp_asn    = 65000
  ip_address = "203.0.113.12"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "onprem_vpn" {
  customer_gateway_id = aws_customer_gateway.paris_dc.id
  transit_gateway_id  = aws_ec2_transit_gateway.hub.id
  type                = "ipsec.1"
  static_routes_only  = false
}
