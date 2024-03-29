terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "brenden-tf-backend"
    key = "sso_test/terraform.tfstate"
    region = "us-east-2"
    profile = "main"
    encrypt = "true"
  }
}

provider aws {
    region = "us-east-2"
    profile = "main"

}