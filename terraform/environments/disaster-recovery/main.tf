module "network" {
  source = "../../modules/vpc"
}

module "tgw" {
  source = "../../modules/tgw"
}

module "security" {
  source = "../../modules/security"
}

module "observability" {
  source = "../../modules/observability"
}
