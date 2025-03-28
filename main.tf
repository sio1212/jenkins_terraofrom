#### VPC ####

resource "aws_vpc" "vpc-test-jenkins" {
  cidr_block  = "10.181.130.0/24" # 업뎃 필요
  enable_dns_hostnames = true
  enable_classiclink = true  # 기본값을 true 또는 false로 설정
  enable_classiclink_dns_support = true  # 기본값을 true 또는 false로 설정

  tags = {
    Name = "vpc-test-jenkins"
  }
}
