output "master_public_ip" {
  value = module.jenkins_master.public_ip
}

/*output "agent_public_ip" {
  value = module.jenkins_agent.public_ip
}*/

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
