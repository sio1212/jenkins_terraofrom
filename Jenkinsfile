pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // Jenkins에 설정된 AWS 자격 증명 ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // Jenkins에 설정된 AWS 비밀 키
    }
    
    stages {
        stage('Checkout') {
            steps {
                // GitHub에서 Terraform 소스 코드 가져오기
                checkout scm
            }
        }
        
        stage('Initialize Terraform') {
            steps {
                script {
                    // Terraform 초기화
                    sh 'terraform init'
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    // Terraform 계획 생성
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    // Terraform 적용
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        always {
            // 작업 후 정리, 로그 출력 등
            sh 'terraform destroy -auto-approve'  // 옵션에 따라 리소스를 자동으로 삭제할 수도 있음
        }
    }
}
