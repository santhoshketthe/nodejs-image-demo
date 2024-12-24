pipeline {
    agent any

    environment {
        IMAGE_NAME = 'my-app'
        CONTAINER_NAME = 'my-app-container'
        EC2_HOST = '35.154.5.164'  // Replace with your EC2 instance IP
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t ${IMAGE_NAME}:latest .'
                }
            }
        }

        stage('Transfer Image to EC2') {
            steps {
                withCredentials([file(credentialsId: 'santhoshinstance', variable: 'PEM_FILE')]) {
                    script {
                        // Prepare the image file for transfer
                        sh """
                        docker save ${IMAGE_NAME}:latest | gzip > ${IMAGE_NAME}.tar.gz
                        scp -i \$PEM_FILE ${IMAGE_NAME}.tar.gz ec2-user@${EC2_HOST}:~/
                        """
                    }
                }
            }
        }

        stage('Post Actions') {
            steps {
                cleanWs()
            }
        }
    }
}
