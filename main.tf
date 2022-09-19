### This is not an operational terrascan file.  
### it's only there to validate the scan.
## it's mailny there to 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "random" {}
resource "random_pet" "bucket_name" {
  length = 2
  separator = "-"
  prefix = "tenable-jam"
}

#provider "aws" {
#  region  = "us-east-1"
 # shared_config_files = [ $HOME/.aws/config ]
#  shared_credentials_files = [ $HOME/.aws/credentials]
#  profile = "demoprofile"
#}

variable "whitelist" {
  type = list(string)
}
variable "web_image_id" {
  type = string
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}



#  The configuration for the `remote` backend.
#  for runnining in github actions
#terraform {
#  backend "remote" {
#  # The name of your Terraform Cloud organization.
#    organization = "Tenable"

#    # The name of the Terraform Cloud workspace to store Terraform state files in.
#    workspaces {
#      name = "User-Demo-workspace"
#    }
#  }
#}
#locals {
#  bucket_name = "s3-bucket-{random_pet.this.id}"
#}


resource "aws_s3_bucket" "awsjamdemo_bucket" {
  bucket = "${random_pet.bucket_name.id}"
  acl    = "private"
  tags = {
    Name = "drift_demo"
  }

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"

  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "drift_demo"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "drift_demo"
  }
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard http and https ports inbound and everything outbound"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
//    cidr_blocks = ["172.31.0.0/28"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
//    cidr_blocks = ["172.31.0.0/28"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "drift_demo"
  }
}