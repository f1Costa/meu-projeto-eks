terraform {
  backend "s3" {
    bucket = "meu-bucket-terraform-state-eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
