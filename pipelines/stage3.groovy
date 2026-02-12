
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Daniyal1Hazari/my-repository.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "job3 successful. Triggering job4..."

            build job: 'job4', wait: true
        }

        failure {
            echo "Terraform Plan failed. job4 will NOT run."
        }
    }
}
