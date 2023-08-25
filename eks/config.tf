terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      terraform  = true
      repository = "uds-infrastructure-software-factory-aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/sh"
    args        = ["-c", "for i in $(seq 1 30); do curl -s -k -f ${module.cluster.cluster_endpoint}/healthz > /dev/null && break || sleep 10; done && aws eks --region ${var.region} get-token --cluster-name ${var.cluster_name}"]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "/bin/sh"
      args        = ["-c", "for i in $(seq 1 30); do curl -s -k -f ${module.cluster.cluster_endpoint}/healthz > /dev/null && break || sleep 10; done && aws eks --region ${var.region} get-token --cluster-name ${var.cluster_name}"]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/sh"
    args        = ["-c", "for i in $(seq 1 30); do curl -s -k -f ${module.cluster.cluster_endpoint}/healthz > /dev/null && break || sleep 10; done && aws eks --region ${var.region} get-token --cluster-name ${var.cluster_name}"]
  }
}
