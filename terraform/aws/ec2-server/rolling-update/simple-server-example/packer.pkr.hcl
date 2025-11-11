variable "ami_name" {
  type = string
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = "g4dn.xlarge"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu-build-base"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["!!! here owner id of AWS"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "mkdir /home/ubuntu/server"
    ]
  }

  provisioner "file" {
    source = "./"
    destination = "/home/ubuntu/server"
  }

  provisioner "file" {
    source = "server.service"
    destination = "/etc/systemd/system/server.service"
  }

  provisioner "shell" {
    inline = [
      "cd /home/ubuntu/server", 
      "sudo docker build -t server:latest .", 
      "sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT",
      "sudo systemctl enable server",
      "sudo systemctl start server"
    ]
  }
}