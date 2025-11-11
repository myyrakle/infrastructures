terraform {
  required_providers {
    # 일종의 라이브러리 로드
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "server" {
  tags = {
    Name = var.server_name
  }

  ami           = "ami-0e9bfdb247cc8de84"
  instance_type = "t2.micro"
}
