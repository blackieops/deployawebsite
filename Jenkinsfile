pipeline {
	agent { dockerfile true }

	stages {
		stage("Build") {
			steps {
				sh "bundle install --path vendor/bundle"
				sh "make"
			}
		}

		stage("Deploy") {
			when { branch "master" }

			environment {
				AWS_ACCESS_KEY_ID = credentials("aws_access_key_id")
				AWS_SECRET_ACCESS_KEY = credentials("aws_secret_access_key")
			}

			steps {
				sh "aws s3 sync --delete dist/ s3://www.deployawebsite.com/"
			}
		}
	}
}
