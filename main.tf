provider "aws" {
  region = "ap-northeast-2" # 원하는 리전으로 변경
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}
