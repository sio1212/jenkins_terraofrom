#### Basic Information ####
  
# Provider Information
provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  # Library 버전
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  # Terraform 버전
  required_version = ">= 0.13"

  }

#### Remote State Data Source ####
#data "aws_availability_zones" "all" {}
