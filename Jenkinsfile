pipeline {
    agent any

    stages {       
        stage ('Build Images') {
            steps {
                script {
                    def dirs = ["user-service", "product-service", "cart-service", "frontend"]
                    dirs.each { index ->
                                dir("${index}") {
                                    echo "Building Image: ${index}"
                                    sh "docker build -t rahmaahmed2002/depi_gp-${index}:${env.BUILD_NUMBER} ."
                                    
                                }   
                        
                    
                    }
                }
            }
        }

        stage ('Trivy Scan') {
            steps {
                script {
                    def dirs = ["user-service", "product-service", "cart-service", "frontend"]
                    dirs.each { index ->
                                    echo "Critical Vulnerability Scan: ${index}"
                                    sh "trivy image --severity CRITICAL --report summary  rahmaahmed2002/depi_gp-${index}:${env.BUILD_NUMBER}"                 
                    
                    }
                }
            }
        }

        stage ('Push Images') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub_cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // login to dockerhub
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        def svc = ["user-service", "product-service", "cart-service", "frontend"]
                        svc.each { index ->
                                    echo "Push ${index} to dockerhub"
                                    sh "docker push rahmaahmed2002/depi_gp-${index}:${env.BUILD_NUMBER}"             
                        }
                        sh 'docker logout'
                    }
                }
            }
        }

        stage ('Clean Up') {
            steps {
                script {
                    echo 'cleaning up space...'
                    sh 'docker system prune -af'
                }
            }
        }
    }
}
