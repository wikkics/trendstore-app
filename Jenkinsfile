pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/wikkics/trendstore-app.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

    }
}
