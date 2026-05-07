terraform {
  backend "s3" {
    bucket = "your-tf-state-bucket"
    key    = "production/terraform.tfstate"
    region = "eu-west-1"
  }
}
