terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0" # AWS provider 버전을 명시합니다. 필요에 따라 버전을 조절하세요.
    }
  }
}

provider "aws" {
  region = var.region
}
