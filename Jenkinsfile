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
        FLASK_URL = "http://54.180.158.54:5000/send/slack/message"
    }

    stages {
        stage('Plan') {
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

        stage('Slack Notification for Approval') {
            when {
                expression { !params.autoApprove && !params.isDestroy }
            }
            steps {
                script {
                    sh """
                    curl -X POST -H 'Content-Type: application/json' \
                    -d '{"build_number": "${env.BUILD_NUMBER}"}' \
                    ${FLASK_URL}
                    """
                }
            }
        }

        stage('Approval') {
            when {
                expression { !params.autoApprove && !params.isDestroy }
            }
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        input id: 'Proceed', message: "Terraform 배포 승인 대기중...", ok: "승인"
                    }
                }
            }
        }

        stage('Apply') {
            when {
                expression { !params.isDestroy }
            }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }

        stage('Destroy') {
            when { expression { params.isDestroy } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
