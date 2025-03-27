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
                    sh 'terraform init -upgrade'  
                    sh 'terraform validate'  

                    script {  // ✅ `script {}` 블록 안에서 `if` 문 사용
                        if (params.isDestroy) {  
                            sh 'terraform plan -destroy'  
                        } else {
                            sh 'terraform plan -out=tfplan'  
                        }
                    }
                }
            }
        }

        stage('Drift Check') {
            steps {
                script {
                    def driftResult = sh(script: '''
                        set +e
                        driftctl scan --from tfstate+s3://$S3_BUCKET/$TF_STATE_KEY --output json > drift_report.json
                        DRIFT_STATUS=$?
                        if [ $DRIFT_STATUS -ne 0 ]; then
                            echo "🚨 Driftctl 실행 오류 발생! 배포 중지"
                            exit 1
                        fi
                        set -e
                        jq '.summary' drift_report.json
                    ''', returnStdout: true).trim()

                    echo "Drift Check Summary: ${driftResult}"

                    if (driftResult.contains('"total_changed": 0') && driftResult.contains('"total_missing": 0') && driftResult.contains('"total_unmanaged": 0')) {
                        echo "✅ No drift detected. Proceeding with deployment."
                    } else {
                        echo "⚠️ Drift detected! Manual approval required."
                        currentBuild.result = 'UNSTABLE'
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
                    def userInput = input message: "Drift detected! Review and approve before proceeding.",  
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
            when { expression { !params.isDestroy && (params.autoApprove || currentBuild.result != 'UNSTABLE') } }  
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "TF_IN_AUTOMATION=1 terraform apply -auto-approve"
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
