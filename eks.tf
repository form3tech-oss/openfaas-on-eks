module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"

  cluster_enabled_log_types = [
    "api",
  ]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_name                    = "${var.eks_cluster_name}"
  cluster_version                 = "${var.eks_cluster_version}"

  subnets = "${concat(module.vpc.private_subnets, module.vpc.public_subnets)}"
  vpc_id  = "${module.vpc.vpc_id}"

  worker_groups = [
    {
      asg_desired_capacity = "${var.eks_wg_1_size}"
      asg_min_size         = "${var.eks_wg_1_size}"
      asg_max_size         = "${var.eks_wg_1_size}"
      instance_type        = "${var.eks_wg_1_instance_type}"
      name                 = "${var.eks_cluster_name}-wg-1"
      subnets              = "${module.vpc.private_subnets}"
    }
  ]

  write_kubeconfig = true
}
