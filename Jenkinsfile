pipeline {
    agent any
    
    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'test', 'prod'],
            description: '选择部署环境'
        )
    }
    
    environment {
        DOCKER_IMAGE = 'my-go-app'
        DOCKER_TAG = 'latest'
        DOCKER_REGISTRY = 'docker.unsee.tech'
        // 直接定义服务器列表
        DEV_SERVERS = '117.72.75.178'
        TEST_SERVERS = '192.168.2.101,192.168.2.102,192.168.2.103'
        PROD_SERVERS = '10.0.1.101,10.0.1.102,10.0.1.103,10.0.1.104'
        // SSH 用户名改为 root 默认情况是 jenkins
        DEPLOY_USER = 'root'
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
                    // 根据环境选择服务器列表
                    def serverList = []
                    switch(params.DEPLOY_ENV) {
                        case 'dev':
                            serverList = env.DEV_SERVERS.split(',')
                            break
                        case 'test':
                            serverList = env.TEST_SERVERS.split(',')
                            break
                        case 'prod':
                            serverList = env.PROD_SERVERS.split(',')
                            break
                    }
                    
                    // 构建和部署命令
                    def deployCmd = """
                        cd ${env.WORKSPACE} && \
                        docker build -t ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG} . && \
                        docker stop ${DOCKER_IMAGE} || true && \
                        docker rm ${DOCKER_IMAGE} || true && \
                        docker run -d \
                            --name ${DOCKER_IMAGE} \
                            -p 9000:9000 \
                            ${DOCKER_REGISTRY}/${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                    
                    // 使用 SSH Agent 批量部署到所有服务器
                    sshagent(['deploy-key']) {
                        serverList.each { server ->
                            echo "Deploying to server: ${server}"
                            sh "ssh -o StrictHostKeyChecking=no ${env.DEPLOY_USER}@${server} '${deployCmd}'"
                        }
                    }
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