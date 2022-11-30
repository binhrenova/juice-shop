variable "cluster_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_private_access" {
  type = bool
}

variable "cluster_endpoint_public_access" {
  type = bool
}

variable "cluster_additional_security_group_ids" {
  type    = list(string)
  default = []
}

variable "node_group_spot" {
  type = object(
    {
      instance_types       = list(string)
      capacity_type        = string
      max_capacity         = number
      min_capacity         = number
      desired_capacity     = number
      force_update_version = bool
    }
  )

  default = {
    instance_types       = ["t3a.medium", "t3.medium"]
    capacity_type        = "SPOT"
    max_capacity         = 5
    min_capacity         = 0
    desired_capacity     = 1
    force_update_version = true
  }

  description = "Node group configuration"
}

variable "node_group_ondemand" {
  type = object(
    {
      instance_types       = list(string)
      capacity_type        = string
      max_capacity         = number
      min_capacity         = number
      desired_capacity     = number
      force_update_version = bool
    }
  )

  default = {
    instance_types       = ["t3a.medium"]
    capacity_type        = "ON_DEMAND"
    max_capacity         = 5
    min_capacity         = 1
    desired_capacity     = 1
    force_update_version = true
  }

  description = "Node group configuration"
}

variable "worker_group_bottlerocket" {
  type = object(
    {
      instance_types      = list(string)
      capacity_type       = string
      max_capacity        = number
      min_capacity        = number
      desired_capacity    = number
      spot_instance_pools = number
    }
  )

  default = {
    instance_types      = ["t3a.medium", "t3.medium"]
    capacity_type       = "SPOT"
    max_capacity        = 5
    min_capacity        = 0
    desired_capacity    = 0
    spot_instance_pools = 2
  }

  description = "Bottlerocket worker group configuration"
}


variable "capacity_type" {}

variable "instance_types" {
  type = list(string)
}

variable "node_tags" {
  default = {}
}

variable "tags" {
  default = {}
}

#### 2022-05-06

variable "min_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "desired_size" {
  type = string
}

# variable "ami_id" {
#   type = string
# }

# variable "ami_optimized" {
#   type = bool
#   default = true
# }

variable "node_group_name" {
  type = string
}

variable "node_security_group_name" {
  type = string
}

variable "node_iam_role_name" {
  type = string
}

variable "node_security_group_additional_rules" {
  type = any
}

# 2022-05-13

variable "node_kubernetes_taints" {
  default = {}
}

variable "cluster_additional_managed_node_groups" {
  default = {}
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

variable "volume_iops" {
  type = number
}

variable "volume_throughput" {
  type = number
}

# 2022-07-15

variable "bootstrap_docker_config" {
  type = string
}
