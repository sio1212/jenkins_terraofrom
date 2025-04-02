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
    }

    stages {
        stage('Plan') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    script {
                        sh 'terraform init -upgrade'
                        sh 'terraform validate'
                        if (params.isDestroy) {
                            sh 'terraform plan -destroy -out=tfplan'
                        } else {
                            sh 'terraform plan -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Approval') {
            when {
                expression { currentBuild.result == 'UNSTABLE' && !params.autoApprove }
            }
            steps {
                script {
                    def userInput = input message: "Review and approve before proceeding.",
                          parameters: [
                              choice(name: 'APPLY_ACTION', choices: ['승인', '거절'], description: 'Terraform Apply 실행 여부')
                          ]
                    if (userInput == '거절') {
                        error("🚨 사용자가 배포를 거절했습니다. 종료합니다.")
                    } else {
                        echo "✅ 승인 완료! Terraform Apply 진행"
                    }
                }
            }
        }

        stage('Apply') {
            when {
                expression { !params.isDestroy && (params.autoApprove || currentBuild.result != 'UNSTABLE') }
            }
            steps {
                script {
                    echo "Applying Terraform Plan..."
                    build job: 'terraform-apply-job', parameters: [
                        string(name: 'awsRegion', value: params.awsRegion),
                        booleanParam(name: 'isDestroy', value: params.isDestroy)
                    ]
                }
            }
        }

        stage('Destroy') {
            when {
                expression { params.isDestroy }
            }
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
