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
        stage('Transfer Image to EC2') {
            steps {
                withCredentials([file(credentialsId: 'santhoshinstance', variable: 'PEM_FILE')]) {
                    script {
                        sh """
                        mkdir -p ~/.ssh
                        chmod 700 ~/.ssh
                        
                        # Add EC2 host key to known_hosts
                        ssh-keyscan -H 35.154.5.164 >> ~/.ssh/known_hosts
                        
                        # Save Docker image directly and transfer to EC2
                        docker save ${IMAGE_NAME}:latest | gzip > ${IMAGE_NAME}.tar.gz
                        scp -i \$PEM_FILE ${IMAGE_NAME}.tar.gz ${EC2_HOST}:~/
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
                        ssh -i \$PEM_FILE ${EC2_HOST} <<'EOF'
                            set -e
                            
                            # Remove any old Docker image file
                            rm -f ${IMAGE_NAME}.tar.gz
                            
                            # Load the Docker image
                            gzip -d ${IMAGE_NAME}.tar.gz
                            docker load < ${IMAGE_NAME}.tar
                            
                            # Stop and remove the old container if it exists
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            
                            # Run the new container
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
