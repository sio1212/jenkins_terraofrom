pipeline {
    agent any
    
    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        TF_LOG = 'DEBUG'  // 디버깅을 위한 환경 변수 설정
    }

    stages {
        stage('Check Terraform Installation') {
            steps {
                script {
                    echo 'Checking Terraform Installation and Version...'
                    sh 'which terraform'  // terraform 경로 확인
                    sh 'terraform --version'  // terraform 버전 확인
                }
            }
        }
        
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Check Terraform Path') {
            steps {
                script {
                    echo 'Checking Terraform Path and Permissions...'
                    sh 'which terraform'  // terraform 경로 확인
                    sh 'ls -l /usr/bin/terraform'  // terraform 파일 권한 확인
                }
            }
        }
        
        stage('Initialize Terraform') {
            steps {
                script {
                    echo 'Initializing Terraform...'
                    sh '/usr/bin/terraform init -input=false'
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    echo 'Planning Terraform...'
                    sh '/usr/bin/terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    echo 'Applying Terraform...'
                    sh '/usr/bin/terraform apply -auto-approve tfplan'
                }
            }
        }
    }
    
    post {
        always {
            // 로그 확인 또는 리소스 정리 작업을 할 수 있음
        }
    }
}
