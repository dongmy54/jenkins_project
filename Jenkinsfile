pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'my-go-app'
        DOCKER_TAG = 'latest'
        // 如果使用私有仓库，替换为你的 Docker Registry 地址
        DOCKER_REGISTRY = 'docker.unsee.tech'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build and Deploy') {
            steps {
                script {
                    // 使用 Docker 多阶段构建
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    
                    // 停止并删除旧容器（如果存在）
                    sh """
                        docker stop ${DOCKER_IMAGE} || true
                        docker rm ${DOCKER_IMAGE} || true
                    """
                    
                    // 运行新容器
                    sh """
                        docker run -d \
                            --name ${DOCKER_IMAGE} \
                            -p 9000:9000 \
                            ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }
    }
    
    post {
        failure {
            echo 'Pipeline failed! Please check the logs.'
        }
        success {
            echo 'Pipeline succeeded! Application is deployed.'
        }
    }
}