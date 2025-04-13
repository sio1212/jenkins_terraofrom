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
        DYNAMODB_TABLE = "jgt-terraform-lock"
        FLASK_URL = "http://43.201.70.209:5000/send/slack/message"
    }

    stages {
        stage('Terraform Init & Plan') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh """
                    terraform init -backend-config="bucket=${S3_BUCKET}" \
                                   -backend-config="key=${TF_STATE_KEY}" \
                                   -backend-config="region=${AWS_REGION}" \
                                   -backend-config="encrypt=true" \
                                   -upgrade

                    terraform validate
                    """

                    script {
                        if (params.isDestroy) {
                            sh 'terraform plan -destroy -out=tfplan'
                        } else {
                            sh 'terraform plan -out=tfplan'
                        }
                    }

                    // plan 결과 저장
                    script {
                        env.TF_OUTPUT = sh(script: "terraform show -no-color tfplan", returnStdout: true).trim()
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
                    def payload = [
                        build_number: env.BUILD_NUMBER,
                        plan_output : env.TF_OUTPUT.take(2900)  // Slack 제한 대비
                    ]
                    writeFile file: 'payload.json', text: groovy.json.JsonOutput.toJson(payload)

                    sh """
                    curl -X POST -H 'Content-Type: application/json' \
                    --data @payload.json \
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

        stage('Terraform Apply') {
            when {
                expression { !params.isDestroy }
            }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.isDestroy }
            }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }
    }
}
