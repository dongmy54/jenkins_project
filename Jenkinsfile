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
                    // 读取服务器配置
                    // def servers = readJSON file: 'servers.json'
                    // def targetServers = servers.environments[params.DEPLOY_ENV].servers
                    // 读取服务器配置
                    // 读取服务器配置
                    def jsonContent = readFile(file: 'servers.json')
                    def serversJson = new groovy.json.JsonSlurperClassic().parseText(jsonContent)
                    def targetServers = serversJson.environments[params.DEPLOY_ENV].servers
                    
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
                        targetServers.each { server ->
                            echo "Deploying to server: ${server}"
                            sh "ssh -o StrictHostKeyChecking=no ${server} '${deployCmd}'"
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