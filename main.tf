#### VPC ####

resource "aws_vpc" "vpc-test-jenkins" {
  cidr_block  = "10.181.130.0/24" # 업뎃 필요
  enable_dns_hostnames = true
  enable_dns_support = true
 
  enable_classiclink           = false  # 필요한 경우 true/false로 설정
  enable_classiclink_dns_support = false  # 필요한 경우 true/false로 설정
  tags = {
    Name = "vpc-test-jenkins"
  }
}
