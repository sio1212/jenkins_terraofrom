pipeline {
    agent any

    environment {
        AWS_REGION = "ap-northeast-2"  // 원하는 리전
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')  // AWS 자격 증명 ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')  // AWS 비밀 키
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sio1212/jenkins_terraofrom.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
