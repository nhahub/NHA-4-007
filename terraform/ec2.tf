# Jenkins Server
data "aws_key_pair" "key" {
  key_pair_id = "key-0088437e537d75f65"
}

resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-091138d0f0d41ff90"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet["public_subnet_1"].id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.key.key_name
  user_data                   = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    apt update
    apt install -y fontconfig openjdk-21-jre
    
    # Install Jenkins
    wget -O /etc/apt/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
    echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
      https://pkg.jenkins.io/debian-stable binary/ | tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt update
    apt install -y jenkins
    
    # Install Docker
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    
    # Add jenkins user to docker group
    usermod -aG docker jenkins
    usermod -aG docker ubuntu
    
    # Start Jenkins
    systemctl start jenkins
    systemctl enable jenkins
    
  EOF
  
  tags = {
    Name = "Jenkins Server"
  }
}



output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}
output "name" {
  value = data.aws_key_pair.key.key_name
}