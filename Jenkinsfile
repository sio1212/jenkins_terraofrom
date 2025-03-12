pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
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
                    // terraform init 명령 실행 및 출력 확인
                    sh 'terraform init -input=false'
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
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
