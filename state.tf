# Terraform의 백엔드 설정 (상태 파일을 저장할 위치 및 방법을 지정)
terraform {
  backend "s3" {
    # S3 버킷 이름 - 이 버킷에 Terraform 상태 파일이 저장됩니다.
    bucket = "jgt-terraform-state"  # 생성한 S3 버킷 이름

    # S3에 상태 파일을 저장할 경로 (디렉토리 경로 + 파일 이름)
    key    = "terraform.tfstate"  # 상태 파일을 저장할 경로

    # S3 버킷이 위치한 AWS 리전
    region = "ap-northeast-2"  # S3 버킷이 위치한 리전

    # 상태 파일을 암호화하여 저장 (보안 강화)
    encrypt = true  # S3에 저장된 상태 파일을 암호화

    # 상태 파일에 대한 버전 관리 활성화 (파일 변경 이력을 보관)
    versioning = true  # S3 버킷에서 버전 관리 활성화 (상태 파일의 변경 이력을 보관)
  }
}

# AWS Provider 설정 (Terraform에서 AWS와 상호작용을 위한 설정)
provider "aws" {
  region = "ap-northeast-2"  # AWS 리전 설정 (여기서는 서울 리전)
}

# 예시로 사용할 리소스 (AWS S3 버킷 생성)
resource "aws_s3_bucket" "jgt-terraform-state" {
  bucket = "jgt-terraform-state"  # S3 버킷 이름 (기존에 만든 이름 사용)
  acl    = "private"  # 접근 제어 목록 (ACL) 설정, private으로 설정하여 모든 사람이 접근하지 못하도록 설정
}

# 기타 추가 리소스를 여기에 정의할 수 있습니다.
