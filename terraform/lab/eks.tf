locals {
  eks_tags = {
    team = "devops"
  }

  docker_config = {
    "bridge" : "none",
    "log-driver" : "json-file",
    "log-opts" : {
      "max-size" : "50m",
      "max-file" : "10"
    }
  }

  node_security_group_additional_rules = {}
}

module "eks" {
  source = "../modules/container/eks"

  project_name = var.project_name
  env          = var.env_name

  cluster_name       = var.eks_cluster_name
  kubernetes_version = var.eks_cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_additional_security_group_ids = []

  vpc_id             = module.prod_vpc.id
  private_subnet_ids = [for p in module.prod_subnet_private : p.id]

  # Managed Node Group (Default)
  node_group_name          = "${var.eks_cluster_name}-01"
  node_security_group_name = "${var.eks_cluster_name}-01-sg"
  node_iam_role_name       = "${var.eks_cluster_name}-01-iam-role"

  bootstrap_docker_config = tostring(jsonencode(local.docker_config))

  capacity_type  = "SPOT"
  instance_types = ["t3.medium", "t3a.medium", "t3a.small", "t3.small"]
  min_size       = 2
  max_size       = 4
  desired_size   = 2

  volume_size       = 10
  volume_type       = "gp3"
  volume_iops       = 3000
  volume_throughput = 125

  node_security_group_additional_rules = local.node_security_group_additional_rules

  node_tags = merge(local.tags, local.eks_tags, {
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"                 = "true"
  })

  node_kubernetes_taints = {}

  tags = merge(local.tags, local.eks_tags)
}
