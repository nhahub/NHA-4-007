# these outputs used in Jenknins kubeconfig
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}

output "cluster_arn" {
    value = module.eks.cluster_arn
}