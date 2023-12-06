pipeline {
    agent none
    environment {
        IMAGE_NAME = 'docker_hub'
        HUB_CRED_ID = 'someCredID'
    }
    stages {
        stage("deps") {
            agent {
                docker {
                    image 'python:latest'
                    args '-u root -v ${WORKSPACE}/pipenv:/root/.local'
                }
            }
            steps {
                sh 'pip install --user -r requirements.txt'
            }
        }
        stage("test") {
            agent {
                docker {
                    image 'python:latest'
                    args '-u root -v ${WORKSPACE}/pipenv:/root/.local'
                }
            }
            steps {
                sh 'python -m coverage run manage.py test'
            }
        }
        stage("report") {
            agent {
                docker {
                    image 'python:latest'
                    args '-u root -v ${WORKSPACE}/pipenv:/root/.local'
                }
            }
            steps {
                sh 'python -m coverage report'
            }
        }
        stage("build") {
            agent any
            steps {
                sh 'docker build . -t ${IMAGE_NAME}:${GIT_COMMIT}'
            }
        }
        stage("push") {
            agent any
            steps {
                withCredentials([usernamePassword(credentialsId: "${HUB_CRED_ID}",
                usernameVariable: 'HUB_USERNAME', passwordVariable: 'HUB_PASSWORD')]) {
                    sh 'docker login -u ${HUB_USERNAME} -p ${HUB_PASSWORD}'
                    sh 'docker push ${IMAGE_NAME}:${GIT_COMMIT}'
                }
            }
        }
    }
}