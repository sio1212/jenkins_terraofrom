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
        SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
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
                expression { !params.autoApprove }
            }
            steps {
                script {
                    def slackMessage = """
                    {
                      "blocks": [
                        {
                          "type": "section",
                          "text": {
                            "type": "mrkdwn",
                            "text": "*[Terraform 배포 승인 요청]*"
                          }
                        },
                        {
                          "type": "actions",
                          "elements": [
                            {
                              "type": "button",
                              "text": {
                                "type": "plain_text",
                                "text": "승인"
                              },
                              "style": "primary",
                              "value": "approve_${env.BUILD_NUMBER}",
                              "action_id": "approve_action"
                            },
                            {
                              "type": "button",
                              "text": {
                                "type": "plain_text",
                                "text": "거절"
                              },
                              "style": "danger",
                              "value": "reject_${env.BUILD_NUMBER}",
                              "action_id": "reject_action"
                            }
                          ]
                        }
                      ]
                    }
                    """
                    sh """
                    curl -X POST -H 'Content-type: application/json' --data '${slackMessage}' ${SLACK_WEBHOOK_URL}
                    """
                }
            }
        }

        stage('Approval') {
            when {
                expression { !params.autoApprove }
            }
            steps {
                script {
                    def userInput = input message: "승인 또는 거절을 선택하세요", parameters: [choice(name: 'APPLY_ACTION', choices: ['승인', '거절'], description: 'Terraform 실행 여부')]
                    if (userInput == '거절') {
                        error("사용자 거절로 배포 중단")
                    }
                }
            }
        }

        stage('Apply') {
            when {
                expression { !params.isDestroy && (params.autoApprove || currentBuild.result != 'UNSTABLE') }
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
