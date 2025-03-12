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
                    // 디버깅: Terraform 경로와 상태를 출력
                    sh 'which terraform'  // terraform 경로 확인
                    sh 'ls -l /usr/bin/terraform'  // terraform 파일 정보 확인
                    // terraform init 명령어 실행
                    sh '/usr/bin/terraform init -input=false'
                }
            }
        }
        
        stage('Plan Terraform') {
            steps {
                script {
                    echo 'Planning Terraform...'
                    // terraform plan 명령어 실행
                    sh '/usr/bin/terraform plan -out=tfplan'
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    echo 'Applying Terraform...'
                    // terraform apply 명령어 실행
                    sh '/usr/bin/terraform apply -auto-approve tfplan'
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
