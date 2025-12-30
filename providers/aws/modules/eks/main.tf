resource "aws_eks_cluster" "main" {
  name     = "kube-cluster"
  role_arn = aws_iam_role.cluster_role.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    
  }
  vpc_config {
    subnet_ids = var.subnet_ids
  }

  version = "1.34"
}

resource "aws_iam_role" "cluster_role" {
  name = "kube-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "kube-node-group"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.subnet_ids

  launch_template {
    name    = aws_launch_template.eks_nodes.name
    version = aws_launch_template.eks_nodes.latest_version
  }
  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  instance_types = ["t3.small"]
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "eks-node-group-template"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforces IMDSv2
    http_put_response_hop_limit = 2          # ALLOWS PODS TO REACH METADATA
    instance_metadata_tags      = "enabled"
  }
}

resource "aws_iam_role" "node_group_role" {
  name = "kube-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "cluster_access_role" {
  name = "ClusterAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cluster_access_policy" {
  name = "eks-access-policy"
  role = aws_iam_role.cluster_access_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = aws_eks_cluster.main.arn
      }
    ]
  })
}

resource "aws_eks_access_entry" "cluster_access_role" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = aws_iam_role.cluster_access_role.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "cluster_access_role" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.cluster_access_role.arn

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "admin_user" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_user" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/admin"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "primary_pipeline_role" {
  cluster_name      = aws_eks_cluster.main.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PrimaryPipelineRole"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "primary_pipeline_role" {
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/PrimaryPipelineRole"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
}
