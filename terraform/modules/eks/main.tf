module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.0"

  name    = var.cluster_name
  kubernetes_version = var.cluster_version

  endpoint_public_access  = true
  endpoint_private_access = true
  # Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"

  # Restrict public access to your local machine IP 
  endpoint_public_access_cidrs = var.allowed_public_cidrs
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    metrics-server = {
      most_recent = true  
    }
  }

  
  # Node Groups
  eks_managed_node_groups = {
    example = {
    name           = "main-node-group"
    desired_size   = 3    
    min_size       = 2    
    max_size       = 4    
    instance_types = var.system_node_instance_type
    disk_size      = 30   # Root volume size 
  }
  }

  enable_irsa = true

  access_entries = {
    # Jenkins Role
    jenkins = {
      principal_arn     = var.principal_arn 
      user_name         = "jenkins"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } 
}

