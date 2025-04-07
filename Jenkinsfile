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
        SLACK_WEBHOOK_URL = credentials('slack-webhook-url')  // Jenkins Credentials
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

        stage('Slack Approval') {
            when { 
                allOf {
                    expression { !params.autoApprove }
                    expression { !params.isDestroy }
                }
            }
            steps {
                script {
                    def message = """
                    {
                        "blocks": [
                            {
                                "type": "section",
                                "text": {
                                    "type": "mrkdwn",
                                    "text": "*Terraform 배포 승인 요청*\\nRegion: ${params.awsRegion}\\nDestroy: ${params.isDestroy}"
                                }
                            },
                            {
                                "type": "actions",
                                "elements": [
                                    {
                                        "type": "button",
                                        "text": {
                                            "type": "plain_text",
                                            "text": "배포 승인"
                                        },
                                        "style": "primary",
                                        "url": "http://43.203.232.137:8080/job/${env.JOB_NAME}/${env.BUILD_NUMBER}/input"
                                    },
                                    {
                                        "type": "button",
                                        "text": {
                                            "type": "plain_text",
                                            "text": "배포 거절"
                                        },
                                        "style": "danger",
                                        "url": "http://43.203.232.137:8080/job/${env.JOB_NAME}/${env.BUILD_NUMBER}/input"
                                    }
                                ]
                            }
                        ]
                    }
                    """
                    
                    sh """
                        curl -X POST -H 'Content-type: application/json' --data '${message}' ${SLACK_WEBHOOK_URL}
                    """

                    input message: "Slack에서 배포 승인을 눌러주세요"  
                }
            }
        }

        stage('Apply') {
            when { expression { !params.isDestroy && (params.autoApprove || currentBuild.result != 'FAILURE') } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    echo "Terraform Apply 실행"
                    sh "TF_IN_AUTOMATION=1 terraform apply -auto-approve tfplan"
                }
            }
        }

        stage('Destroy') {
            when { expression { params.isDestroy } }
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    echo "Terraform Destroy 실행"
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }
}
