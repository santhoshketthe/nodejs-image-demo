pipeline {
    agent any
    environment {
        EC2_HOST = 'ec2-user@35.154.5.164' // Replace with your EC2 instance's public IP/hostname
        IMAGE_NAME = 'my-app'
        CONTAINER_NAME = 'my-app-container'
    }
    stages {
        stage('Checkout Latest Code') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }
        stage('Save Docker Image') {
            steps {
                script {
                    sh """
                        docker save ${IMAGE_NAME}:latest | gzip > ${IMAGE_NAME}.tar.gz
                    """
                }
            }
        }
        stage('Transfer Image to EC2') {
            steps {
                withCredentials([file(credentialsId: 'santhoshinstance', variable: 'PEM_FILE')]) {
                    script {
                         sh """
                        # Ensure .ssh directory exists
                        mkdir -p ~/.ssh
                        chmod 700 ~/.ssh
                        
                        # Add EC2 host key to known_hosts
                        ssh-keyscan -H 35.154.5.164 >> ~/.ssh/known_hosts
                        
                        # Transfer the Docker image to the EC2 instance
                        scp -i $PEM_FILE ${IMAGE_NAME}.tar.gz ${EC2_HOST}:~/
                        """
                    }
                }
            }
        }
        stage('Deploy on EC2') {
            steps {
                withCredentials([file(credentialsId: 'santhoshinstance', variable: 'PEM_FILE')]) {
                    script {
                        sh """
                        ssh -i $PEM_FILE ${EC2_HOST} << EOF
                            gzip -d ${IMAGE_NAME}.tar.gz
                            docker load < ${IMAGE_NAME}.tar
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            docker run -d --name ${CONTAINER_NAME} -p 8082:8082 ${IMAGE_NAME}:latest
                        EOF
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed."
        }
        always {
            cleanWs()  // Clean up the workspace
        }
    }
}
