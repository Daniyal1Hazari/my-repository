
        stage('Deploy NGINX Application') {
            steps {
                sh '''
                echo "Installing NGINX..."

                sudo yum install -y nginx git

                echo "Starting and enabling NGINX..."

                sudo systemctl enable nginx
                sudo systemctl start nginx

                APP_DIR=/usr/share/nginx/html/app

                echo "Deploying application..."

                sudo rm -rf $APP_DIR
                sudo git clone https://github.com/Daniyal1Hazari/my-repository.git $APP_DIR

                sudo systemctl restart nginx

                echo "Deployment completed successfully."
                '''
            }
        }
    }

    post {
        success {
            echo "job5 completed successfully. Full pipeline finished."
        }

        failure {
            echo "Deployment failed. Check logs above."
        }
    }
}
