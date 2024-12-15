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
        DOCKER_IMAGE = 'dmy-go-app'
        DOCKER_TAG = 'latest'
        // 直接定义服务器列表
        DEV_SERVERS = '117.72.75.178'
        TEST_SERVERS = '192.168.2.101,192.168.2.102,192.168.2.103'
        PROD_SERVERS = '10.0.1.101,10.0.1.102,10.0.1.103,10.0.1.104'
        // SSH 用户名改为 root 默认情况是 jenkins
        DEPLOY_USER = 'root'
        // 镜像文件名
        IMAGE_TAR = 'dmy-go-app.tar'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Image') {
            steps {
                script {
                    // 构建 Docker 镜像
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    // 保存镜像为文件
                    sh "docker save ${DOCKER_IMAGE}:${DOCKER_TAG} -o ${IMAGE_TAR}"
                }
            }
        }
        
        stage('Deploy') {
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
                    
                    // 部署命令
                    def deployCmd = """
                        docker load -i ${IMAGE_TAR} && \
                        docker stop ${DOCKER_IMAGE} || true && \
                        docker rm -f ${DOCKER_IMAGE} || true && \
                        docker run -d \
                            --name ${DOCKER_IMAGE} \
                            --restart unless-stopped \
                            -p 9000:9000 \
                            ${DOCKER_IMAGE}:${DOCKER_TAG} && \
                        rm -f ${IMAGE_TAR}
                    """
                    
                    // 这里的deploy-key代表的是 jenkins全局配置时中的Id
                    sshagent(['deploy-key']) {
                        serverList.each { server ->
                            echo "Deploying to server: ${server}"
                            // 传输 Docker 镜像文件
                            sh "scp -o StrictHostKeyChecking=no ${IMAGE_TAR} ${env.DEPLOY_USER}@${server}:~/"
                            // 加载镜像并运行容器
                            sh "ssh -o StrictHostKeyChecking=no ${env.DEPLOY_USER}@${server} '${deployCmd}'"
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            // 清理本地镜像文件
            sh "rm -f ${IMAGE_TAR}"
        }
        failure {
            echo 'Pipeline failed! Please check the logs.'
        }
        success {
            echo 'Pipeline succeeded! Application is deployed.'
        }
    }
}