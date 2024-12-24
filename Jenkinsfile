pipeline {

    agent any

    environment {

        EC2_HOST = 'ec2-user@35.154.5.164'

        IMAGE_NAME = 'my-app'

        CONTAINER_NAME = 'my-app-container'

    }

    stages {

        stage('Checkout Latest Code') {

            steps {

                checkout scm // Pulls the latest code from the Git repository configured in Jenkins

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

                script {

                    sh """

                        scp -i ${SSH_KEY_PATH} ${IMAGE_NAME}.tar.gz ${EC2_HOST}:~/

                    """

                }

            }

        }

        stage('Deploy on EC2') {

            steps {

                script {

                    sh """

                        ssh -i ${SSH_KEY_PATH} ${EC2_HOST} << EOF

                            docker load < ${IMAGE_NAME}.tar.gz

                            docker stop ${CONTAINER_NAME} || true

                            docker rm ${CONTAINER_NAME} || true

                            docker run -d --name ${CONTAINER_NAME} -p 8082:8082 ${IMAGE_NAME}:latest

                        EOF

                    """

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

            cleanWs() // Clean up the workspace

        }

    }

}

 
