locals {
  oidc_url = replace(module.eks_cluster.cluster_oidc_issuer_url, "https://", "")
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  create_cloudwatch_log_group = false
  cluster_security_group_additional_rules = {
    ingress_nodes_karpenter_ports_tcp = {
      description                = "Karpenter readiness"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }

    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids

  node_security_group_additional_rules = var.node_security_group_additional_rules

  eks_managed_node_group_defaults = {
    # We are using the IRSA created below for permissions
    # This is a better practice as well so that the nodes do not have the permission,
    # only the VPC CNI addon will have the permission
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = merge(var.cluster_additional_managed_node_groups, {
    default = {
      name            = var.node_group_name
      use_name_prefix = true
      cluster_name    = var.cluster_name
      cluster_version = var.kubernetes_version

      vpc_id     = var.vpc_id
      subnet_ids = var.private_subnet_ids

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = var.volume_type
            iops                  = var.volume_iops
            throughput            = var.volume_throughput
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      # ami_id               = var.ami_id
      # ami_is_eks_optimized = var.ami_optimized

      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
        set -ex
        cat <<-EOF > /etc/profile.d/bootstrap.sh
        export DOCKER_CONFIG_JSON='${var.bootstrap_docker_config}'
        EOF
        # Source extra environment variables in bootstrap script
        sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
      EOT

      instance_types = var.instance_types
      capacity_type  = var.capacity_type

      labels = {
        Env = var.env
      }

      create_iam_role          = true
      iam_role_name            = var.node_iam_role_name
      iam_role_use_name_prefix = true
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      create_security_group          = true
      security_group_name            = var.node_security_group_name
      security_group_use_name_prefix = true

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      security_group_rules = {
        ingress_self_all = {
          description = "Node to node all ports/protocols"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          type        = "ingress"
          self        = true
        }

        egress_all = {
          description      = "Node all egress"
          protocol         = "-1"
          from_port        = 0
          to_port          = 0
          type             = "egress"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = ["::/0"]
        }
      }

      taints = var.node_kubernetes_taints

      tags = merge(var.node_tags, tomap({
        Name                                        = var.node_group_name
        Env                                         = var.env
        "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      }))
    }
  })

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }

    kube-proxy = {}

    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

}

#### v18.x remove "workers_additional_policies"

resource "aws_iam_role_policy_attachment" "additional_ssm_role" {
  for_each = module.eks_cluster.eks_managed_node_groups

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = each.value.iam_role_name
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "4.13.0"

  role_name             = join("-", [var.cluster_name, "vpc-cni"])
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks_cluster.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Name = join("-", [var.cluster_name, "vpc-cni"])
  }
}
