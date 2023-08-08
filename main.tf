data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]

	cluster_addons = {
		vpc-cni = {
			most_recent          = true
			before_compute       = true
			configuration_values = <<-JSON
				{
					"env": {
						"AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG": "true",
						"ENABLE_PREFIX_DELEGATION": "true",
						"ENI_CONFIG_LABEL_DEF": "topology.kubernetes.io/zone",
						"WARM_PREFIX_TARGET": "1",
						"ANNOTATE_POD_IP": "true",
						"POD_SECURITY_GROUP_ENFORCING_MODE": "standard"
					}
				}
			JSON
		}
		coredns = {
			preserve    = true
			most_recent = true

			timeouts = {
				create = "25m"
				delete = "10m"
			}
		}
		kube-proxy = {
			most_recent = true
		}
	}

	eks_managed_node_group_defaults = {
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/node_groups.tf
    ami_type                      = "AL2_x86_64"
    instance_types                = ["m5.2xlarge"]
  }

	capability_node_groups = {
		gitlab_ng = {
			min_size = 
			max_size = 
			desired_size = 
			disk_size = 
		}
	}
}

module "vpc" {
  source = "github.com/defenseunicorns/terraform-aws-swf-vpc?ref=add-vpc"

  name                  = var.name #"oursler-swf"
  vpc_cidr                  = "10.0.0.0/16"
  secondary_cidr_blocks = ["100.64.0.0/16"]
  azs                   = local.azs
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 8)]
  elasticache_subnets   = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 4, k + 12)]
}

# EKS
# I think `vpc_cni_custom_subnet` will be the subets from the secondary CIDR
module "cluster" {
  source = "github.com/defenseunicorns/terraform-aws-uds-eks?ref=v0.0.3"

  name = var.name
  vpc_id                          = module.vpc.vpc_id
  private_subnet_ids              = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.private_subnets
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  source_security_group_id        = module.bastion.security_group_ids[0]
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true
  vpc_cni_custom_subnet           = module.vpc.intra_subnets
  cluster_version                 = "1.26"
  bastion_role_arn                = module.bastion.bastion_role_arn
  bastion_role_name               = module.bastion.bastion_role_name
  cidr_blocks                     = module.vpc.private_subnets_cidr_blocks
  eks_use_mfa                     = false

  # If using EKS Managed Node Groups, the aws-auth ConfigMap is created by eks itself and terraform can not create it
  create_aws_auth_configmap = false #var.create_aws_auth_configmap
  manage_aws_auth_configmap = true #var.manage_aws_auth_configmap

  ######################## EKS Managed Node Group ###################################
  enable_eks_managed_nodegroups = true
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = #local.eks_managed_node_groups

  #---------------------------------------------------------------
  #"native" EKS Add-Ons
  #---------------------------------------------------------------

  cluster_addons = local.cluster_addons

  #---------------------------------------------------------------
  # EKS Blueprints - EKS Add-Ons
  #---------------------------------------------------------------

  # AWS EKS EBS CSI Driver
  enable_amazon_eks_aws_ebs_csi_driver = true#var.enable_amazon_eks_aws_ebs_csi_driver
  amazon_eks_aws_ebs_csi_driver_config = { #var.amazon_eks_aws_ebs_csi_driver_config
		wait        = false
		most_recent = true
	}
	enable_gp3_default_storage_class = true

  # AWS EKS EFS CSI Driver
  enable_efs     = true #var.enable_efs
  reclaim_policy = #var.reclaim_policy

  # AWS EKS node termination handler
  enable_aws_node_termination_handler      = true #var.enable_aws_node_termination_handler
  aws_node_termination_handler_helm_config = { #var.aws_node_termination_handler_helm_config
		wait    = false
		version = "v0.21.0"
	}

  # k8s Metrics Server
  enable_metrics_server      = true #var.enable_metrics_server
  metrics_server_helm_config = {
		wait    = false
		version = "v3.10.0"
	}#var.metrics_server_helm_config

  # k8s Cluster Autoscaler
  enable_cluster_autoscaler      = true #var.enable_cluster_autoscaler
  cluster_autoscaler_helm_config = { #var.cluster_autoscaler_helm_config
		wait    = false
		version = "v9.29.1"
		# set = [
		#   {
		#     name  = "extraArgs.expander"
		#     value = "priority"
		#   },
		#   {
		#     name  = "image.tag"
		#     value = "v1.27.2"
		#   }
		# ]
	}


  #Calico
  enable_calico      = true #var.enable_calico
  calico_helm_config = {
		wait    = false
		version = "v3.26.1"
	}#var.calico_helm_config
}

# RDS

# S3

# ElastiCache

# EFS

# DDB
