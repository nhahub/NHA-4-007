# Jenkins Server
data "aws_key_pair" "key" {
  key_pair_id = "key-0088437e537d75f65"
}

## Associate existing Elastic IP to instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins_instance.id
  allocation_id = "eipalloc-00aba1125ebc82f1e"
}

resource "aws_instance" "jenkins_instance" {
  ami                         = "ami-091138d0f0d41ff90"
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_subnet["public_subnet_1"].id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.key.key_name
  #iam_instance_profile        = aws_iam_instance_profile.jenkins.id
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
    curl -fsSL https://test.docker.com -o test-docker.sh
    sh test-docker.sh
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

  root_block_device {
    delete_on_termination = true
    volume_size           = 12
    volume_type           = "gp3"
  }
}



output "jenkins_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}
output "name" {
  value = data.aws_key_pair.key.key_name
}