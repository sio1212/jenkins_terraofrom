pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

     environment {
        AWS_ACCESS_KEY_ID     = credentials('AKIA34AMC44EMQFTQWQH')
        AWS_SECRET_ACCESS_KEY = credentials('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')
        REGION = credentials('ap-northeast-2')
    }

    stages {

        stage('Plan') {

            steps {
                sh 'terraform init -upgrade'
                sh "terraform validate"
                sh "terraform plan"
            }
        }
        stage('Approval') {
           when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
           }
           
           steps {
               script {
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan')]

               }
           }
       }

        stage('Apply') {
            steps {
                sh "terraform apply --auto-approve"
            }
        }
    }
}
