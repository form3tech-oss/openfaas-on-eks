output "eks_cluster_name" {
    description = "The name of the EKS cluster."
    value       = "${module.eks.cluster_id}"
}

output "eks-cluster-kubeconfig" {
    description = "The path to the kubeconfig file for the EKS cluster."
    value       = "${module.eks.kubeconfig_filename}"
}
