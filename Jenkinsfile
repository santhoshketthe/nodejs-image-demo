pipeline {
    agent any
 
    environment {
        IMAGE_NAME = 'nodejs-docker-app'
        CONTAINER_NAME = 'nodejs-docker-container'
        REMOTE_USER = 'ec2-user'
        REMOTE_HOST = '35.154.5.164' // Replace with your EC2 instance public IP or hostname
        SSH_CREDENTIALS_ID = 'AWS' // Replace with your Jenkins SSH credentials ID
        APP_PORT = '8082' // Application port
    }
 
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image locally
                    sh "docker build -t ${IMAGE_NAME} ."
                   
                    // Save the Docker image as a tar file
                    sh "docker save -o ${IMAGE_NAME}.tar ${IMAGE_NAME}"
                }
            }
        }
 
        stage('Transfer Image to EC2') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY')]) {
                        // Copy the Docker image tar file to the EC2 instance
                        sh """
                        scp -o StrictHostKeyChecking=no -i $SSH_KEY ${IMAGE_NAME}.tar ${REMOTE_USER}@${REMOTE_HOST}:/home/${REMOTE_USER}/
                        """
                    }
                }
            }
        }
 
        stage('Deploy on EC2') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'AWS', keyFileVariable: 'Key')]) {
                        // SSH into the EC2 instance, load the image, and deploy the container
                        sh """
                        ssh -o StrictHostKeyChecking=no -i $SSH_KEY ${REMOTE_USER}@${REMOTE_HOST} << EOF
                            docker load -i /home/${REMOTE_USER}/${IMAGE_NAME}.tar
                            if [ \$(docker ps -q -f name=${CONTAINER_NAME}) ]; then
                                docker stop ${CONTAINER_NAME}
                                docker rm ${CONTAINER_NAME}
                            fi
                            docker run -d -p ${APP_PORT}:${APP_PORT} --name ${CONTAINER_NAME} ${IMAGE_NAME}
                        EOF
                        """
                    }
                }
            }
        }
    }
 
    post {
        success {
            echo "Node.js Docker application deployed successfully on the EC2 instance!"
        }
        failure {
            echo "Deployment failed. Please check the logs for details."
        }
        always {
            cleanWs() // Clean up workspace
        }
    }
}
