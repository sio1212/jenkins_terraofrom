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

                    if (params.isDestroy) {  
                        sh 'terraform plan -destroy'  
                    } else {
                        sh 'terraform plan'  
                    }
                }
            }
        }

        stage('Drift Check') {
            steps {
                script {
                    def driftStatus = sh(script: '''
                        driftctl scan --from tfstate+s3://$S3_BUCKET/$TF_STATE_KEY --output json > drift_report.json
                        jq '.summary' drift_report.json
                    ''', returnStdout: true).trim()

                    echo "Drift Check Summary: ${driftStatus}"

                    if (driftStatus.contains('"total_changed": 0') && driftStatus.contains('"total_missing": 0') && driftStatus.contains('"total_unmanaged": 0')) {
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
                    input message: "Drift detected! Review and approve before proceeding.",  
                          parameters: [text(name: 'Review', description: 'Please review the drift report and confirm.')]
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
