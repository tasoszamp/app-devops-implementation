pipeline {
    agent {
        label 'Build'
    }

    environment {
        IMAGE_NAME = 'anastzampetis/hello-world-api:latest'
    }

    stages {

        stage('Checkout') {
            steps {
                script {
                    try {
                        checkout scm
                    } catch (Exception e) {
                        error "Checkout failed: ${e.message}"
                    }
                }
                //stashing terraform files to use on Deploy agent
                stash includes: 'terraform/**', name: 'tf'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    try {
                        sh "docker build -t $IMAGE_NAME -f DockerfileApp ."
                    } catch (Exception e) {
                        error "Build for image failed: ${e.message}"
                    }
                }
            }
        }

        stage('Test Image') {
            steps {
                script {
                    try {
                        env.CONTAINER_ID = sh(script: 'docker run -d -p 8000:8080 $IMAGE_NAME', returnStdout: true).trim()
                        // Wait for service to start
                        sh "sleep 10"
                        // Run tests
                        sh "/bin/bash ./run-tests.sh"  
                        // Clean up container after use
                        sh '''
                            docker stop ${CONTAINER_ID}
                            docker rm ${CONTAINER_ID}
                        '''
                    } catch (Exception e) {
                        sh '''
                            docker stop ${CONTAINER_ID} || true
                            docker rm ${CONTAINER_ID} || true
                        '''
                        error "Tests failed: ${e.message}"
                    }
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: dockerCredentialsId, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {

                            sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                            sh "docker push $IMAGE_NAME"
                        }
                    } catch (Exception e) {
                        error "Push failed: ${e.message}"
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                label 'Deploy'
            }
            steps {
                unstash 'tf'
                dir('terraform'){
                    script {
                        try {
                            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cli-creds']]) {

                                sh "terraform init"
                                sh "ls -a"
                                sh "terraform apply -auto-approve"
                            }
                        } catch (Exception e) {
                            error "Deployment failed: ${e.message}"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for more details.'
        }
        always {
            cleanWs()
        }
    }
}
