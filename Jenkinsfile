pipeline {
    agent none
    environment {
        IMAGE_NAME = 'jarvis07/jenkins'
        HUB_CRED_ID = 'DevOps_course'
        PROJECT_DIR = 'common_django_demo_ryzhenkov'
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
                sh 'python -m coverage xml'
                sh 'python -m coverage html'
                archiveArtifacts 'htmlcov/*'
            }
        }
        stage("build") {
            agent any
            steps {
                sh 'docker build . -t ${IMAGE_NAME}:${GIT_COMMIT} -t ${IMAGE_NAME}:latest'
            }
        }
        stage("sonar scan") {
            agent any
            steps {
                withCredentials(
                    [
                        string(credentialsId: "sonarqube_url", variable: 'SONARQUBE_URL'),
                        usernamePassword(credentialsId: "sonarqube_token", usernameVariable: 'PROJECT_KEY', passwordVariable: 'PROJECT_TOKEN')
                    ]
                ) {
                    sh '''docker run \
                        --rm \
                        -e SONAR_HOST_URL="${SONARQUBE_URL}" \
                        -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${PROJECT_KEY} -Dsonar.python.coverage.reportPaths=coverage.xml" \
                        -e SONAR_TOKEN="${PROJECT_TOKEN}" \
                        -v "${WORKSPACE}:/usr/src" \
                        sonarsource/sonar-scanner-cli
                    '''
                }
            }
        }
        stage("push") {
            agent any
            steps {
                withCredentials([usernamePassword(credentialsId: "${HUB_CRED_ID}",
                usernameVariable: 'HUB_USERNAME', passwordVariable: 'HUB_PASSWORD')]) {
                    sh 'docker login -u ${HUB_USERNAME} -p ${HUB_PASSWORD}'
                    sh 'docker push ${IMAGE_NAME}:${GIT_COMMIT}'
                    sh 'docker push ${IMAGE_NAME}:latest'
                }
            }
        }
        stage("deploy") {
            agent any
            steps {
                withCredentials(
                    [
                        string(credentialsId: "production_ip", variable: 'SERVER_IP'),
                        sshUserPrivateKey(credentialsId: "production_key", keyFileVariable: 'SERVER_KEY', usernameVariable: 'SERVER_USERNAME')
                    ]
                ) {
                    sh 'ssh -i ${SERVER_KEY} ${SERVER_USERNAME}@${SERVER_IP} mkdir -p ${PROJECT_DIR}'
                    sh 'scp -i ${SERVER_KEY} docker-compose.yaml ${SERVER_USERNAME}@${SERVER_IP}:${PROJECT_DIR}'
                    sh 'ssh -i ${SERVER_KEY} ${SERVER_USERNAME}@${SERVER_IP} docker compose -f ${PROJECT_DIR}/docker-compose.yaml pull'
                    sh 'ssh -i ${SERVER_KEY} ${SERVER_USERNAME}@${SERVER_IP} docker compose -f ${PROJECT_DIR}/docker-compose.yaml up -d'
                }
            }
        }
        stage("proxy config") {
            agent any
            steps {
                withCredentials(
                    [
                        string(credentialsId: "production_ip", variable: 'SERVER_IP'),
                        sshUserPrivateKey(credentialsId: "production_key", keyFileVariable: 'SERVER_KEY', usernameVariable: 'SERVER_USERNAME')
                    ]
                ) {
                    sh 'scp -i ${SERVER_KEY} ryzhenkov.prod.mshp-devops.com.conf ${SERVER_USERNAME}@${SERVER_IP}:nginx'
                    sh 'ssh -i ${SERVER_KEY} ${SERVER_USERNAME}@${SERVER_IP} sudo certbot --nginx --non-interactive --agree-tos -m ryzhenkov@devops.ru -d ryzhenkov.prod.mshp-devops.com'
                    sh 'ssh -i ${SERVER_KEY} ${SERVER_USERNAME}@${SERVER_IP} sudo systemctl reload nginx'
                }
            }
        }
    }
}