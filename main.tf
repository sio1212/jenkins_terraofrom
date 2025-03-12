provider "aws" {
  region = "ap-northeast-2"  # 원하는 AWS 리전으로 수정
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # 원하는 CIDR 블록으로 수정
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
