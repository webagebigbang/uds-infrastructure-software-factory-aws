locals {
  vpc_id          = var.create_test_resources ? module.vpc[0].vpc_id : var.vpc_id
  private_subnets = var.create_test_resources ? module.vpc[0].private_subnets : var.cluster_subnets
  cidr_blocks     = var.create_test_resources ? module.vpc[0].private_subnets_cidr_blocks : var.cidr_blocks
  cni_subnets     = var.create_test_resources ? module.vpc[0].intra_subnets : var.cluster_cni_subnets

  eks_managed_node_group_defaults = {
    # https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/node_groups.tf
    iam_role_permissions_boundary = var.iam_role_permissions_boundary
    ami_type                      = "AL2_x86_64"
    instance_types                = ["m5a.2xlarge", "m5.2xlarge", "m6i.2xlarge"]
    tags = {
      subnet_type = "private",
      cluster     = var.cluster_name
    }
  }

  eks_managed_node_groups = {
    mg_node_group = {
      min_size                   = 3
      max_size                   = 5
      desired_size               = 3
      disk_size                  = 50
      use_custom_launch_template = false
    }
  }
}

# EKS
module "cluster" {
  source = "github.com/defenseunicorns/terraform-aws-uds-eks?ref=v0.0.5"

  name                            = var.cluster_name
  vpc_id                          = local.vpc_id
  private_subnet_ids              = local.private_subnets
  control_plane_subnet_ids        = local.private_subnets
  iam_role_permissions_boundary   = var.iam_role_permissions_boundary
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  vpc_cni_custom_subnet           = local.cni_subnets
  cluster_version                 = "1.26"
  cidr_blocks                     = local.cidr_blocks
  eks_use_mfa                     = false

  # If using EKS Managed Node Groups, the aws-auth ConfigMap is created by eks itself and terraform can not create it
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true

  ######################## EKS Managed Node Group ###################################
  eks_managed_node_group_defaults = local.eks_managed_node_group_defaults
  eks_managed_node_groups         = local.eks_managed_node_groups

  # k8s Cluster Autoscaler
  enable_cluster_autoscaler = true

  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_gp3_default_storage_class     = true

  #Calico
  enable_calico = true

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
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
}

module "vpc" {
  count = var.create_test_resources ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                    = var.cluster_name
  cidr                    = "10.0.0.0/16"
  secondary_cidr_blocks   = ["100.64.0.0/16"]
  azs                     = local.azs
  public_subnets          = [for k, v in module.vpc[0].azs : cidrsubnet(module.vpc[0].vpc_cidr_block, 4, k)]
  private_subnets         = [for k, v in module.vpc[0].azs : cidrsubnet(module.vpc[0].vpc_cidr_block, 4, k + 4)]
  database_subnets        = [for k, v in module.vpc[0].azs : cidrsubnet(module.vpc[0].vpc_cidr_block, 4, k + 8)]
  elasticache_subnets     = [for k, v in module.vpc[0].azs : cidrsubnet(module.vpc[0].vpc_cidr_block, 4, k + 12)]
  intra_subnets           = [for k, v in module.vpc[0].azs : cidrsubnet(element(module.vpc[0].vpc_secondary_cidr_blocks, 0), 5, k)]
  map_public_ip_on_launch = true
  single_nat_gateway      = true
  enable_nat_gateway      = true

  create_redshift_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  vpc_flow_log_permissions_boundary    = var.iam_role_permissions_boundary
}
