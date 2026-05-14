# Jenkins IAM Role to access EKS Cluster
resource "aws_iam_role" "jenkins-eks" {
  name = "jenkins_eks_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "jenkins-eks" {
  name        = "jenkins_eks_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi"
        ]
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins-eks" {
  role       = aws_iam_role.jenkins-eks.name
  policy_arn = aws_iam_policy.jenkins-eks.arn
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins-eks.name
}