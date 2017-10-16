pipeline {
  agent { dockerfile true }

  stages {
    stage("Build") {
      steps {
        sh "/usr/local/hugo/hugo"
      }
    }

    stage("Deploy") {
      when { branch "master" }

      environment {
        AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
        AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
      }

      steps {
        sh "aws s3 sync public/ s3://www.deployawebsite.com/"
      }
    }
  }
}
