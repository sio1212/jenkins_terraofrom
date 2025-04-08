pipeline {
    agent any  

    parameters {
        booleanParam(name: 'isDestroy', defaultValue: false, description: 'Set true to perform terraform destroy')  
        string(name: 'awsRegion', defaultValue: 'ap-northeast-2', description: 'AWS Region for deployment')  
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically apply changes without approval')  
    }

    environment {
        PATH = "/usr/bin:/usr/local/bin:/opt/terraform:/bin"
        AWS_REGION = "${params.awsRegion}"
        S3_BUCKET = "jgt-terraform-state"
        TF_STATE_KEY = "demo/terraform.tfstate"
        SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
        FLASK_API_URL = "http://54.180.158.54:5000/slack/deploy"
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
        expression { currentBuild.result == 'UNSTABLE' && !params.autoApprove }
    }
    steps {
        script {
            def buildNumber = env.BUILD_NUMBER
            def approveUrl = "${FLASK_API_URL}?action=approve&build_number=${buildNumber}"
            def rejectUrl = "${FLASK_API_URL}?action=reject&build_number=${buildNumber}"

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
                      "url": "${approveUrl}"
                    },
                    {
                      "type": "button",
                      "text": {
                        "type": "plain_text",
                        "text": "거절"
                      },
                      "style": "danger",
                      "url": "${rejectUrl}"
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

        stage('Approval Wait') {
            when {
                expression { !params.autoApprove }
            }
            steps {
                script {
                    timeout(time: 15, unit: 'MINUTES') {
                        waitUntil {
                            fileExists("approval_${env.BUILD_NUMBER}.txt")
                        }
                    }

                    def approvalResult = readFile("approval_${env.BUILD_NUMBER}.txt").trim()
                    if (approvalResult == 'reject') {
                        error("🚨 사용자가 배포 거절했습니다. 종료합니다.")
                    } else {
                        echo "✅ 승인 완료! Terraform Apply 진행"
                    }
                }
            }
        }

        stage('Apply') {
            when { expression { !params.isDestroy && (params.autoApprove || fileExists("approval_${env.BUILD_NUMBER}.txt")) } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    script {
                        echo "Applying Terraform Plan..."
                        sh "TF_IN_AUTOMATION=1 terraform apply -auto-approve tfplan"
                    }
                }
            }
        }

        stage('Destroy') {
            when { expression { params.isDestroy } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    script {
                        echo "Destroying Terraform resources..."
                        sh "terraform destroy -auto-approve"
                    }
                }
            }
        }
    }
}
