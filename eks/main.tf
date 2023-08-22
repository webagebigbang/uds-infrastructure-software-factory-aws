locals {
  vpc_id = var.create_test_resources ? module.vpc.vpc_id : var.vpc_id
  private_subnets = var.create_test_resources ? module.vpc.private_subnets : var.cluster_subnets
  cidr_blocks = var.create_test_resources ? module.vpc.private_subnets_cidr_blocks : var.cidr_blocks
  intra_subnets = var.create_test_resources ? module.vpc.intra_subnets : var.intra_subnets

	eks_managed_node_group_defaults = {
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/node_groups.tf
    iam_role_permissions_boundary = var.iam_role_permissions_boundary
    ami_type                      = "AL2_x86_64"
    instance_types                = ["m5a.large", "m5.large", "m6i.large"]
    tags = {
      subnet_type = "private",
      cluster     = var.cluster_name
    }

    # enable discovery of autoscaling groups by cluster-autoscaler
    autoscaling_group_tags = merge(
      local.tags,
      {
        "k8s.io/cluster-autoscaler/enabled" : true,
        "k8s.io/cluster-autoscaler/${local.cluster_name}" : "owned"
    })
  }

  eks_managed_node_groups = {
    mg_node_group = {
      mg_ng = {
        min_size     = 2
        max_size     = 5
        desired_size = 2
        disk_size    = 50
      }
    }
  }
}

# EKS
# I think `vpc_cni_custom_subnet` will be the subets from the secondary CIDR
module "cluster" {
  source = "github.com/defenseunicorns/terraform-aws-uds-eks?ref=v0.0.3"

  name = var.cluster_name
  vpc_id                          = local.vpc_id
  private_subnet_ids              = local.private_subnets
  control_plane_subnet_ids        = local.private_subnets
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  vpc_cni_custom_subnet           = local.intra_subnets
  cluster_version                 = "1.27"
  cidr_blocks                     = local.cidr_blocks #module.vpc.private_subnets_cidr_blocks
  eks_use_mfa                     = false

  # If using EKS Managed Node Groups, the aws-auth ConfigMap is created by eks itself and terraform can not create it
  create_aws_auth_configmap = false #var.create_aws_auth_configmap
  manage_aws_auth_configmap = true #var.manage_aws_auth_configmap

  ######################## EKS Managed Node Group ###################################
  enable_eks_managed_nodegroups = true
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  # k8s Cluster Autoscaler
  enable_cluster_autoscaler      = true
  cluster_autoscaler_helm_config = {
		wait    = false
		version = "v9.29.1"
	}

  #Calico
  enable_calico      = true #var.enable_calico
  calico_helm_config = {
		wait    = false
		version = "v3.26.1"
	}
}

module "vpc" {
  source  = "../vpc/"

  count = var.create_test_resources ? 1 : 0

  name = var.cluster_name
  cidr = "10.0.0.0/16"
  secondary_cidr_blocks = ["100.64.0.0/16"]

  vpc_flow_log_permissions_boundary = var.iam_role_permissions_boundary
}
