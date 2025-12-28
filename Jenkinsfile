pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'pomodoro-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY = 'your-registry' // Замените на ваш Docker registry (если используется)
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Получение кода из Git репозитория...'
                checkout scm
                sh 'git log -1 --pretty=format:"%h - %an, %ar : %s"'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Сборка Docker образа...'
                script {
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    // Также создаем тег latest
                    image.tag("${DOCKER_IMAGE}:latest")
                }
            }
        }
        
        stage('Test') {
            steps {
                echo 'Проверка работоспособности образа...'
                sh '''
                    # Проверяем, что образ создан
                    docker images | grep ${DOCKER_IMAGE}:${DOCKER_TAG}
                    
                    # Запускаем контейнер для проверки
                    docker run -d --name test-container -p 8080:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    sleep 5
                    
                    # Проверяем, что контейнер запущен
                    docker ps | grep test-container
                    
                    # Проверяем доступность приложения (опционально)
                    # curl -f http://localhost:8080 || exit 1
                    
                    # Останавливаем тестовый контейнер
                    docker stop test-container
                    docker rm test-container
                '''
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
            // Очистка старых образов (опционально)
            sh '''
                # Удаляем старые образы (оставляем последние 5)
                docker images ${DOCKER_IMAGE} --format "{{.ID}}" | tail -n +6 | xargs -r docker rmi || true
            '''
        }
    }
}


