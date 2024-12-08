terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
    backend "s3" {
      key="aws/ec2-deploy/terraform.tfstate"
    }
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources to."
}
provider "aws" {
  region = var.region
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key file."
}

variable "key_name" {
  type        = string
  description = "The name of the key pair."
}
variable "public_key" {
  type        = string
  description = "The name of the key pair."
}
resource "aws_instance" "server" {
    ami = "ami-0453ec754f44f9a4a"
    instance_type = "t2.micro"
    key_name = aws_key_pair.deploy.key_name
    vpc_security_group_ids = [aws_security_group.maingroup.id]
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

    connection {
        type = "ssh"
        host = self.public_ip
        user="Linux"
        private_key = var.private_key_path
        timeout = "4m"
    }
    tags = {
        "Name" = "terraform-deploy"
    }
}
resource "aws_iam_instance_profile" "ec2_profile" {
    name="ec2_profile"
    role= "EC2-ECR-AUTH"
  
}

resource "aws_security_group" "maingroup" {
  egress = [
    {
       cidr_blocks = ["0.0.0.0/0"]
       description = ""
       from_port = 0
       ipv6_cidr_blocks = []
       prefix_list_ids = []
       protocol = "-1"
       security_groups = []
       self = false
       to_port = 0 
    }
  ]
  ingress = [
    {
       cidr_blocks = ["0.0.0.0/0"]
       description = ""
       from_port = 22
       ipv6_cidr_blocks = []
       prefix_list_ids = []
       protocol = "tcp"
       security_groups = []
       self = false
       to_port = 22 
    },
    {
       cidr_blocks = ["0.0.0.0/0"]
       description = ""
       from_port = 80
       ipv6_cidr_blocks = []
       prefix_list_ids = []
       protocol = "tcp"
       security_groups = []
       self = false
       to_port = 80
       }
  ]
  name = "maingroup"
}


resource "aws_key_pair" "deploy" {
    key_name=var.key_name
    public_key=var.public_key
  
}

output "instance_public_ip" {
    value = aws_instance.server.public_ip
    sensitive = true
  
}

