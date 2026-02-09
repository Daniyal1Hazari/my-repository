pipeline {
  agent any
  options {        
    timestamps()
     }
  stages {        
    stage('Checkout Application Code') 
    {            
      steps 
      {                
        git branch: 'main',
          url: 'https://github.com/Daniyal1Hazari/my-repository.git'            
      }
    }
    stage('Terraform Init') 
    {
      steps 
      {
        dir('terraform') 
        {
          sh 'terraform init'
        }
      }
    }
    stage('Terraform Plan') 
    {
      steps 
      {
        dir('terraform') 
        {
          sh 'terraform plan -out=tfplan'
        }
      }
    }
    stage('Terraform Apply') 
    {
      steps {
        dir('terraform') 
        {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }
    stage('Deploy NGINX Application')
    {
      steps 
      {
        sh '''                
        sudo yum install -y nginx git
        sudo systemctl enable nginx
        sudo systemctl start nginx
        APP_DIR=/usr/share/nginx/html/app
        sudo rm -rf $APP_DIR
        sudo git clone https://github.com/Daniyal1Hazari/my-repository.git $APP_DIR
        sudo systemctl restart nginx
        '''
      }
    }
  }
}

