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
      version = "~> 3.20"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  # Terraform 버전
  required_version = ">= 0.13"

  # State 저장용 S3 Backend 구성
  backend "s3" {
    bucket = "" #S3 버킷명
    key    = "" #terraform.tfstate 파일위치 ex) aws-an2/jenkins_terraform_test/terraform.tfstate
    region = "ap-northeast-2" # 리전
    dynamodb_table = "" #테라폼 백엔드 구성용 DynamoDB 테이블명
    encrypt = true
  }
}

#### Remote State Data Source ####
data "aws_availability_zones" "all" {}
