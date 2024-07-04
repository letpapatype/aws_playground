packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "time_stamp" {
  type    = string
  default = "dude"
}

variable "aws_access_key" {
  type    = string
  default = "dude"
}

variable "aws_secret_key" {
  type    = string
  default = "dude"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "ubuntu-dev-box-${var.time_stamp}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "aws-packer-ubuntu"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    script = "provision.sh"
  }

  provisioner "shell" {
    inline = [
      "aws configure -aws_access_key_id=${var.aws_access_key} -aws_secret_access_key=${var.aws_secret_key}"
    ]
  }
}

