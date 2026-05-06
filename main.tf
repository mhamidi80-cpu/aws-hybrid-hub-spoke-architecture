# --- Spoke A: Production ---
resource "aws_vpc" "spoke_a" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "Spoke-A-PROD" }
}

resource "aws_subnet" "spoke_a_subnet" {
  vpc_id            = aws_vpc.spoke_a.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-west-3a"
  tags              = { Name = "Spoke-A-Subnet" }
}

# Attach Spoke A to the Hub
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_a_attach" {
  subnet_ids         = [aws_subnet.spoke_a_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = aws_vpc.spoke_a.id
  tags               = { Name = "TGW-Attach-Spoke-A" }
}

# --- Spoke B: Development ---
resource "aws_vpc" "spoke_b" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "Spoke-B-DEV" }
}

resource "aws_subnet" "spoke_b_subnet" {
  vpc_id            = aws_vpc.spoke_b.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-west-3a"
  tags              = { Name = "Spoke-B-Subnet" }
}

# Attach Spoke B to the Hub
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_b_attach" {
  subnet_ids         = [aws_subnet.spoke_b_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.hub.id
  vpc_id             = aws_vpc.spoke_b.id
  tags               = { Name = "TGW-Attach-Spoke-B" }
}

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

# --- Routing for Spoke A ---
resource "aws_route_table" "spoke_a_rt" {
  vpc_id = aws_vpc.spoke_a.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.hub.id
  }

  tags = { Name = "Spoke-A-RT" }
}

resource "aws_route_table_association" "spoke_a_assoc" {
  subnet_id      = aws_subnet.spoke_a_subnet.id
  route_table_id = aws_route_table.spoke_a_rt.id
}

# --- Routing for Spoke B ---
resource "aws_route_table" "spoke_b_rt" {
  vpc_id = aws_vpc.spoke_b.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.hub.id
  }

  tags = { Name = "Spoke-B-RT" }
}

resource "aws_route_table_association" "spoke_b_assoc" {
  subnet_id      = aws_subnet.spoke_b_subnet.id
  route_table_id = aws_route_table.spoke_b_rt.id
}

