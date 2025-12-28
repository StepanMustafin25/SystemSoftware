pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'pomodoro-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'your-registry' 
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Получение кода из Git репозитория...'
                checkout scm
                script {
                    if (isUnix()) {
                        sh 'git log -1 --pretty=format:"%h - %an, %ar : %s"'
                    } else {
                        bat 'git log -1 --pretty=format:"%%h - %%an, %%ar : %%s"'
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Сборка Docker образа...'
                script {
                    if (isUnix()) {
                        sh 'docker --version'
                    } else {
                        bat 'docker --version'
                    }
                    
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    
                    if (isUnix()) {
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } else {
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Проверка работоспособности образа...'
                script {
                    if (isUnix()) {
                        sh '''
                            # Проверяем, что образ создан
                            docker images | grep ${DOCKER_IMAGE}:${DOCKER_TAG}
                            
                            # Запускаем контейнер для проверки
                            docker run -d --name test-container -p 8080:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                            sleep 5
                            
                            # Проверяем, что контейнер запущен
                            docker ps | grep test-container
                            
                            # Останавливаем тестовый контейнер
                            docker stop test-container
                            docker rm test-container
                        '''
                    } else {
                        bat '''
                            @echo off
                            REM Проверяем, что образ создан
                            docker images | findstr %DOCKER_IMAGE%:%DOCKER_TAG%
                            
                            REM Запускаем контейнер для проверки
                            docker run -d --name test-container -p 8080:80 %DOCKER_IMAGE%:%DOCKER_TAG%
                            timeout /t 5 /nobreak >nul
                            
                            REM Проверяем, что контейнер запущен
                            docker ps | findstr test-container
                            
                            REM Останавливаем тестовый контейнер
                            docker stop test-container
                            docker rm test-container
                        '''
                    }
                }
            }
        }
        
        stage('Push to Registry') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo 'Отправка образа в Docker registry...'
                script {
                    // Раскомментируйте, если используете Docker registry
                    // docker.withRegistry('https://your-registry.com') {
                    //     docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    //     docker.image("${DOCKER_IMAGE}:latest").push()
                    // }
                    echo "Образ ${DOCKER_IMAGE}:${DOCKER_TAG} готов к отправке в registry"
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline выполнен успешно!'
            echo "Docker образ: ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
        failure {
            echo 'Pipeline завершился с ошибкой!'
        }
        always {
            script {
                if (isUnix()) {
                    sh '''
                        # Удаляем старые образы (оставляем последние 5)
                        docker images ${DOCKER_IMAGE} --format "{{.ID}}" | tail -n +6 | xargs -r docker rmi || true
                    '''
                }
            }
        }
    }
}



