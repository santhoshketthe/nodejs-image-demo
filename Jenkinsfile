stage('Save Docker Image') {
    steps {
        sh """
            docker save my-app:latest | gzip > my-app.tar.gz
        """
    }
}
stage('Transfer Image to EC2') {
    steps {
        withCredentials([file(credentialsId: 'f8cf1fe9-d355-4819-9c5e-318db8fe19b1', variable: 'Key')]) {
            sh """
                scp -i $SSH_KEY my-app.tar.gz ec2-user@35.154.5.164:~/
            """
        }
    }
}
stage('Deploy on EC2') {
    steps {
        withCredentials([file(credentialsId: 'f8cf1fe9-d355-4819-9c5e-318db8fe19b1', variable: 'SSH_KEY')]) {
            sh """
                ssh -i $SSH_KEY ec2-user@35.154.5.164 << EOF
                    docker load < my-app.tar.gz
                    docker stop my-app-container || true
                    docker rm my-app-container || true
                    docker run -d --name my-app-container -p 8082:8082 my-app:latest
                EOF
            """
        }
    }
}
