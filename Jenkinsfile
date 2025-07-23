pipeline {
    agent any

    parameters {
        booleanParam(name: 'isDestroy', defaultValue: false, description: 'Set true to perform terraform destroy')
        string(name: 'awsRegion', defaultValue: 'ap-northeast-2', description: 'AWS Region for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically apply changes without approval')
    }

    environment {
        AWS_REGION = "${params.awsRegion}"
        S3_BUCKET = "jgt-terraform-state"
        TF_STATE_KEY = "demo/terraform.tfstate"
        SONARQUBE_ENV = "sonarqube"  // Jenkins에서 등록한 SonarQube 이름
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/sio1212/jenkins_terraofrom.git', branch: 'main'
            }
        }

        stage('Terraform Plan') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh 'terraform init -upgrade'
                    sh 'terraform validate'
                    script {
                        if (params.isDestroy) {
                            sh 'terraform plan -destroy -out=tfplan'
                        } else {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('SonarQube Scan') {
            when {
                expression { !params.isDestroy }
            }
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh "mvn clean verify sonar:sonar"
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { !params.isDestroy && params.autoApprove }
            }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.isDestroy }
            }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
