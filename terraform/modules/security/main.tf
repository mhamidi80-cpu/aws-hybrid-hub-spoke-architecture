resource "aws_networkfirewall_firewall_policy" "hub_policy" {
  name = "hub-inspection-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  }
}

resource "aws_networkfirewall_firewall" "hub_firewall" {
  name                = "hub-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.hub_policy.arn
  vpc_id              = var.inspection_vpc_id

  subnet_mapping {
    subnet_id = var.public_subnet_id
  }

  tags = {
    Name = "Hub-Firewall"
  }
}
