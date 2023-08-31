output "cluster_name" {
  description = "Cluster name"
  value       = module.cluster.cluster_name
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.cluster.cluster_status
}

output "cluster_sg" {
  description = "EKS cluster security group ID"
  value       = module.cluster.cluster_security_group_id
}
