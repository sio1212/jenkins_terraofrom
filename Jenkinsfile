pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        TF_LOG = 'DEBUG'  // 디버깅을 위한 환경 변수 설정
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Initialize Terraform') {
            steps {
                script {
                    echo 'Initializing Terraform...'
                    // Terraform 경로를 지정하여 terraform init 실행
                    sh '/usr/bin/terraform init -input=false'  // Terraform 설치 경로를 /usr/bin/terraform로 설정
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    echo 'Planning Terraform...'
                    // Terraform 경로를 지정하여 terraform plan 실행
                    sh '/usr/bin/terraform plan -out=tfplan'  // Terraform 설치 경로를 /usr/bin/terraform로 설정
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    echo 'Applying Terraform...'
                    // Terraform 경로를 지정하여 terraform apply 실행
                    sh '/usr/bin/terraform apply -auto-approve tfplan'  // Terraform 설치 경로를 /usr/bin/terraform로 설정
                }
            }
        }
    }
    
    post {
        always {
            // 추가적으로 로그 확인 또는 리소스 정리 작업을 할 수 있음
        }
    }
}
