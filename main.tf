terraform {
  backend "s3" {
    bucket = "terraform-back-gt"  # S3 버킷 이름
    key    = "terraform.tfstate"            # 상태 파일이 저장될 경로
    region = "ap-northeast-2"                    # AWS 리전
    encrypt = true                          # 상태 파일 암호화
 #   dynamodb_table = "terraform-locks"      # 상태 파일 잠금을 위한 DynamoDB 테이블 (선택 사항)
  }
}

# VPC 생성 예시
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}
