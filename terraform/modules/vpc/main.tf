resource "aws_vpc" "inspection_vpc" {
  cidr_block           = var.inspection_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Hub-Inspection-VPC"
  }
}

resource "aws_subnet" "hub_transit_a" {
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = "10.100.10.0/28"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "Hub-Transit-Subnet-A"
  }
}

resource "aws_subnet" "hub_transit_b" {
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = "10.100.10.16/28"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "Hub-Transit-Subnet-B"
  }
}

resource "aws_subnet" "hub_public_subnet" {
  vpc_id                  = aws_vpc.inspection_vpc.id
  cidr_block              = "10.100.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "Hub-Public-Subnet"
  }
}

resource "aws_vpc" "spoke_a" {
  cidr_block           = var.spoke_a_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Spoke-A-PROD"
  }
}

resource "aws_subnet" "spoke_a_subnet" {
  vpc_id            = aws_vpc.spoke_a.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "Spoke-A-Subnet"
  }
}

resource "aws_vpc" "spoke_b" {
  cidr_block           = var.spoke_b_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Spoke-B-DEV"
  }
}

resource "aws_subnet" "spoke_b_subnet" {
  vpc_id            = aws_vpc.spoke_b.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "Spoke-B-Subnet"
  }
}

resource "aws_internet_gateway" "hub_igw" {
  vpc_id = aws_vpc.inspection_vpc.id

  tags = {
    Name = "Hub-IGW"
  }
}
