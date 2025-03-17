pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply or destroy after generating plan?')
        booleanParam(name: 'isDestroy', defaultValue: false, description: 'Perform terraform destroy operation?')  // destroy 여부 파라미터 추가
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AKIA34AMC44EMQFTQWQH')
        AWS_SECRET_ACCESS_KEY = credentials('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')
        REGION = credentials('ap-northeast-2')
        PATH = "/usr/bin:/usr/local/bin:/opt/terraform:/bin"
    }

    stages {
        stage('Build') {
            steps {
                sh 'echo $PATH'  // PATH 확인
                sh 'which terraform'  // terraform 실행 경로 확인
                sh 'terraform version'  // terraform 버전 확인
            }
        }

        stage('Plan') {
            steps {
                sh 'terraform init -upgrade'  // terraform 초기화
                sh "terraform validate"  // 코드 유효성 검사
                sh "terraform plan"  // terraform 계획 실행
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove  // autoApprove가 false일 때만 실행
                }
            }
            steps {
                script {
                    input message: "Do you want to apply or destroy the plan?",
                          parameters: [text(name: 'Plan', description: 'Please review the plan')]
                }
            }
        }

        stage('Apply') {
            when {
                expression { !params.isDestroy }  // destroy가 아니면 apply 실행
   
