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


# --- Security Group for Spoke A (Production) ---
resource "aws_security_group" "spoke_a_web_sg" {
  name        = "spoke-a-web-sg"
  description = "Allow web traffic and internal SSH"
  vpc_id      = aws_vpc.spoke_a.id

  # Allow Web Traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH only from your Paris Office/VPN Range
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Internal corporate range
  }

  # Outbound: Allow everything
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Spoke-A-Web-SG" }
}

# --- Security Group for Spoke B (Development) ---
resource "aws_security_group" "spoke_b_dev_sg" {
  name   = "spoke-b-dev-sg"
  vpc_id = aws_vpc.spoke_b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.2.1.0/24"] # Only allow SSH from within the same subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Spoke-B-Dev-SG" }
}



# 1. Add Internet Gateway to the Hub VPC
resource "aws_internet_gateway" "hub_igw" {
  vpc_id = aws_vpc.inspection_vpc.id
  tags   = { Name = "Hub-IGW" }
}

# 2. Create a Public Subnet for the Bastion
resource "aws_subnet" "hub_public_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"
  tags                    = { Name = "Hub-Public-Subnet" }
}

# 3. Security Group for Bastion (SSH from YOUR IP only)
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.inspection_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, replace with your actual Home/Office IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. The Bastion Instance (t3.micro is free-tier eligible)
resource "aws_instance" "bastion" {
  ami                    = "ami-05b457b541faec0ca" # Amazon Linux 2023 in eu-west-3
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.hub_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = { Name = "Bastion-Jump-Server" }
}


