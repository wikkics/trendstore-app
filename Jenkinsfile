pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_IMAGE          = 'wikkics/trendstore-app'
        IMAGE_TAG             = "${BUILD_NUMBER}"
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION            = 'us-east-1'
        EKS_CLUSTER_NAME      = 'trendstore-cluster'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh """
                    docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                    docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo 'Pushing image to DockerHub...'
                sh """
                    echo ${DOCKERHUB_CREDENTIALS_PSW} | \
                    docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                """
            }
        }

        stage('Configure kubectl') {
            steps {
                echo 'Configuring kubectl for EKS...'
                sh """
                    aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
                    aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
                    aws configure set default.region ${AWS_REGION}
                    aws eks update-kubeconfig \
                        --name ${EKS_CLUSTER_NAME} \
                        --region ${AWS_REGION}
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl set image deployment/trendstore-app-deployment \
                        trendstore-app=${DOCKER_IMAGE}:${IMAGE_TAG}
                    kubectl rollout status deployment/trendstore-app-deployment
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh """
                    kubectl get pods
                    kubectl get service trendstore-app-service
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Application deployed!'
        }
        failure {
            echo 'Pipeline failed. Check logs for errors.'
        }
        always {
            sh 'docker logout'
        }
    }
}
