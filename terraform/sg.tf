##### 1. Jenkins Server SG ###########
resource "aws_security_group" "jenkins_sg" {
  name        = "Jenkins Server SG"
  description = "Allow ssh and port 8080 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "depi"
  }
}

# allowing SSH to Jenkins Instance
resource "aws_vpc_security_group_ingress_rule" "jenkins_inbound" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# allowing default port of Jenkins 8080
resource "aws_vpc_security_group_ingress_rule" "jenkins_outbound" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

# allowing Jenkins to hit the control plan API
resource "aws_vpc_security_group_egress_rule" "jenkins_to_cluster" {
  security_group_id            = aws_security_group.jenkins_sg.id
  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow jenkins instance to talk to EKS API"
}

# allowing all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.jenkins_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
##############################################################################


######## 2. EKS Cluster SG ###############
resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster-sg"
  vpc_id      = aws_vpc.main.id
  description = "EKS cluster control plane"
}

# Allow worker nodes to reach cluster API
resource "aws_vpc_security_group_ingress_rule" "cluster_api_from_nodes" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_nodes.id 
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow Worker Nodes to reach cluster API"
}

# Allow Jenkins to access Cluster API
resource "aws_vpc_security_group_ingress_rule" "from_jenkins_to_cluster" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.jenkins_sg.id 
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
  description                  = "Allow Jenkins to access Cluster API"
}

# Allow cluster to reach nodes (kubelet)
resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "tcp"
  description                  = "Allow cluster to nodes"
}
###########################################################################

######### 3. Node SG ############
resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg"
  vpc_id      = aws_vpc.main.id
  description = "EKS worker nodes"
}

# Node-to-node communication
resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_nodes.id 
  ip_protocol                  = "-1"
  description                  = "Allow unrestricted node-to-node traffic"
}

# Cluster can reach nodes (kubelet)
resource "aws_vpc_security_group_ingress_rule" "cluster_to_node_kubelet" {
  security_group_id            = aws_security_group.eks_nodes.id
  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 10250
  to_port                      = 10250
  ip_protocol                  = "tcp"
  description                  = "Allow cluster to reach kubelet"
}

# Nodes can reach the internet
resource "aws_vpc_security_group_egress_rule" "nodes_to_internet" {
  security_group_id = aws_security_group.eks_nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow nodes to reach internet (Docker Hub, K8s packages)"
}