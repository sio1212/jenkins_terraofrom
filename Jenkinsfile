pipeline {
    agent any

    environment {
        PATH = "/usr/bin:/usr/local/bin:/opt/terraform:/bin"
        AWS_REGION = "ap-northeast-2"
    }

    stages {
        stage('Plan') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: 'ap-northeast-2') {
                    sh 'terraform init -upgrade'  // terraform 초기화
                    sh 'terraform validate'  // 코드 유효성 검사
                    sh 'terraform plan'  // terraform 계획 실행
                }
            }
        }

        stage('Apply') {
            when { expression { !params.isDestroy } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: 'ap-northeast-2') {
                    sh "terraform apply -auto-approve"
                }
            }
        }

        stage('Destroy') {
            when { expression { params.isDestroy } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: 'ap-northeast-2') {
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
