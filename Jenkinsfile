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
                    // terraform init 명령 실행
                    echo 'Initializing Terraform...'
                    sh 'terraform init -input=false'
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    // terraform plan 명령 실행
                    echo 'Plan Terraform...'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    // terraform apply 명령 실행
                    echo 'Apply Terraform...'
                    sh 'terraform apply -auto-approve tfplan'
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
