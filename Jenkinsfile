pipeline {
    agent any

    environment {
        IMAGE_NAME = 'my-app'
        CONTAINER_NAME = 'my-app-container'
        EC2_HOST = 'your-ec2-instance-ip'  // Replace with your EC2 instance IP
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

        stage('Deploy on EC2') {
            steps {
                withCredentials([file(credentialsId: 'santhoshinstance', variable: 'PEM_FILE')]) {
                    script {
                        // Deploy the image on EC2
                        sh """
                        ssh -i \$PEM_FILE ec2-user@${EC2_HOST} <<'EOF'
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

        stage('Post Actions') {
            steps {
                cleanWs()
            }
        }
    }
}
