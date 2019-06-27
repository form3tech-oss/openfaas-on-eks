variable "eks_cluster_name" {
    description = "The name of the EKS cluster."
    type        = "string"
}

variable "eks_cluster_version" {
    default     = "1.13"
    description = "The version of the EKS cluster."
    type        = "string"
}

variable "eks_wg_1_instance_type" {
    default     = "m5.large"
    description = "The type of instances to use when provisioning the initial worker group."
    type        = "string"
}

variable "eks_wg_1_size" {
    default     = "2"
    description = "The number of worker nodes on the initial worker group."
    type        = "string"
}

variable "letsencrypt_email" {
    description = "The email address to use when creating the Let's Encrypt ClusterIssuer resources."
    type        = "string"
}

variable "openfaas_clusterissuer_name" {
    default     = "letsencrypt-staging"
    description = "The name of the ClusterIssuer resource to use for provisioning the certificate used by the OpenFaaS ingress."
    type        = "string"
}

variable "openfaas_host" {
    description = "The host at which OpenFaaS will be exposed (NOTE: DNS must be configured separately)."
    type        = "string"
}

variable "openfaas_username" {
    default     = "admin"
    description = "The username to use for OpenFaaS."
    type        = "string"
}

variable "openfaas_password" {
    description = "The password to use for OpenFaaS."
    type        = "string"
}

variable "vpc_cidr" {
    default     = "10.30.0.0/16"
    description = "The CIDR block for the VPC."
    type        = "string"
}

variable "vpc_name" {
    description = "The name of the VPC."
    type        = "string"
}

variable "vpc_availability_zones" {
    default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    description = "List of availability zones within a single region."
    type        = "list"
}

variable "vpc_private_subnets" {
    default     = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
    description = "List of private subnet CIDRs within the VPC."
    type        = "list"
}

variable "vpc_public_subnets" {
    default     = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
    description = "List of public subnet CIDRs within the VPC."
    type        = "list"
}
