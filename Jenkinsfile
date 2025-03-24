pipeline {
    agent any  // 모든 Jenkins 실행 노드에서 실행 가능하도록 설정

    // 🔹 Jenkins Job 실행 시 선택할 수 있는 파라미터 정의
    parameters {
        booleanParam(name: 'isDestroy', defaultValue: false, description: 'Set true to perform terraform destroy')  // Terraform destroy 여부 결정
        string(name: 'awsRegion', defaultValue: 'ap-northeast-2', description: 'AWS Region for deployment')  // AWS 배포 리전 설정
    }

    // 🔹 환경 변수 설정 (Terraform 실행 환경)
    environment {
        PATH = "/usr/bin:/usr/local/bin:/opt/terraform:/bin"  // Terraform 실행을 위한 PATH 설정
        AWS_REGION = "${params.awsRegion}"  // Jenkins Job 실행 시 AWS 리전 선택 가능하도록 설정
    }

    stages {
        // 📌 1️⃣ Terraform Plan 단계 (실행 계획 확인)
        stage('Plan') {
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {  // AWS Credentials 사용
                    sh 'terraform init -upgrade'  // Terraform 초기화 (모듈 및 플러그인 최신화)
                    sh 'terraform validate'  // Terraform 코드 유효성 검사

                    if (params.isDestroy) {  
                        sh 'terraform plan -destroy'  // 🔥 Destroy 모드일 경우 `plan -destroy` 실행
                    } else {
                        sh 'terraform plan'  // 🛠 일반적인 Apply 모드에서는 `plan` 실행
                    }
                }
            }
        }

        // 📌 2️⃣ 사용자 승인 단계 (autoApprove가 false일 때만 실행)
        stage('Approval') {
            when { not { equals expected: true, actual: params.autoApprove } }  // autoApprove가 false일 경우만 실행
            steps {
                script {
                    input message: "Do you want to apply or destroy the plan?",  // 사용자에게 실행 여부 확인 요청
                          parameters: [text(name: 'Plan', description: 'Please review the plan')]
                }
            }
        }

        // 📌 3️⃣ Apply 단계 (isDestroy가 false일 경우 실행)
        stage('Apply') {
            when { expression { !params.isDestroy } }  // isDestroy가 false일 때만 실행 (일반적인 배포)
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform apply -auto-approve"  // Terraform Apply 실행 (자동 승인)
                }
            }
        }

        // 📌 4️⃣ Destroy 단계 (isDestroy가 true일 경우 실행)
        stage('Destroy') {
            when { expression { params.isDestroy } }  // isDestroy가 true일 때만 실행 (리소스 삭제)
            steps {
                withAWS(credentials: 'aws-access-key-id', region: "${params.awsRegion}") {
                    sh "terraform destroy -auto-approve"  // Terraform Destroy 실행 (자동 승인)
                }
            }
        }
    }
}
