#### VPC ####

resource "aws_vpc" "vpc-test-jenkins" {
  cidr_block  = "10.181.130.0/24" # 업뎃 필요
  enable_dns_hostnames = true
  enable_dns_support = true
#sasdasdasd
  tags = {
    Name = "vpc-test-jenkins"
  }
}
