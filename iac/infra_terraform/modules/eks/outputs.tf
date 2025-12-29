output "cluster_name" {
  description = "Nom du cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint du cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Données du certificat d'autorité du cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_id" {
  description = "ID du cluster EKS"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "ARN du cluster EKS"
  value       = module.eks.cluster_arn
}

output "cluster_security_group_id" {
  description = "ID du security group du cluster"
  value       = module.eks.cluster_security_group_id
}

