pipeline {
    agent none
    // environment {
    //     AWS_ACCESS_KEY_ID = credentials('aws_access_key_id')
    //     AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    //     AWS_DEFAULT_REGION = 'ap-south-1'
    // }
    stages {
        stage('TF Init') {
        //    agent any
            steps {
                sh 'terraform init'
            }
        }
        stage('TF Validate') {
         //   agent any
            steps {
                sh 'terraform validate'
            }
        }
        stage('TF Plan') {
        //    agent any
            steps {
                sh 'terraform plan'
            }
        }
        stage('TF Apply') {
        //    agent any
            steps {
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Invoke Lambda') {
        //    agent any
            steps {
                sh 'aws lambda invoke --function-name devops-candidate-lambda --region ap-south-1 output.txt'
                sh 'cat output.txt'
            }
        }
    }
}
