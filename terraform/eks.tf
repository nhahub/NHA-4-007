resource "aws_eks_cluster" "cluster" {
  name = "ecommerce"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30"

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet["private_subnet_1"].id, aws_subnet.private_subnet["private_subnet_2"].id]
    endpoint_private_access = true
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"] # restict with your IP
    security_group_ids = [aws_security_group.eks_cluster.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}
##############################################################################

### Configuring Acess Entries to Cluster ###

# 1. trust Admin User
resource "aws_eks_access_entry" "admin_access" {
  cluster_name      = aws_eks_cluster.cluster.name
  principal_arn     = "arn:aws:iam::440763701841:user/rahma"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::440763701841:user/rahma"

  access_scope {
    type       = "cluster"
  }
}

resource "aws_eks_access_entry" "root_access" {
  cluster_name      = aws_eks_cluster.cluster.name
  principal_arn     = "arn:aws:iam::440763701841:root"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "root_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::440763701841:root"

  access_scope {
    type       = "cluster"
  }
}

### 2. Trust Jenkins Server
resource "aws_eks_access_entry" "jenkins_access" {
  cluster_name      = aws_eks_cluster.cluster.name
  principal_arn     = aws_iam_role.jenkins-eks.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "jenkins_access" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.jenkins-eks.arn

  access_scope {
    type       = "cluster"
  }
}
###################################################

##### Node Group #####

# defining launch to attach node sg (as there is no variable for sg in aws_eks_node_group)
resource "aws_launch_template" "eks_nodes" {
  name = "eks-node-template"
  vpc_security_group_ids = [aws_security_group.eks_nodes.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
        volume_size = 20
    }
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "ecommerce-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids = [aws_subnet.private_subnet["private_subnet_1"].id, aws_subnet.private_subnet["private_subnet_2"].id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  launch_template {
    id = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  instance_types = ["t3.small"]
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [aws_iam_role_policy_attachment.node_policies]
}
#######################################################

#### Cluster add-ons ####
resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"
   pod_identity_association  {
        role_arn        = "arn:aws:iam::440763701841:role/AmazonEKSPodIdentityAmazonEBSCSIDriverRole"
        service_account = "aws-node"
    }
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "aws-ebs-csi-driver"
  pod_identity_association {
    role_arn = "arn:aws:iam::440763701841:role/AmazonEKSPodIdentityAmazonEBSCSIDriverRole" # default policy
    service_account = "ebs-csi-controller-sa"
  }
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "eks-pod-identity-agent"
}

####################################################

# these outputs used in Jenknins kubeconfig
output "cluster_name" {
value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
value = aws_eks_cluster.cluster.endpoint
}

output "cluster_iam_role_arn" {
value = aws_eks_node_group.nodes.node_role_arn
}

output "cluster_arn" {
value = aws_eks_cluster.cluster.arn
}

output "cluster_certificate_authority_data" {
value = aws_eks_cluster.cluster.certificate_authority
}