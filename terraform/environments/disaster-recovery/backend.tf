terraform {
  backend "s3" {
    bucket = "your-tf-state-bucket"
    key    = "dr/terraform.tfstate"
    region = "eu-west-1"
  }
}
