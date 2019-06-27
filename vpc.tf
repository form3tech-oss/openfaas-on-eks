module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "~> 2.0"

    azs                    = "${var.vpc_availability_zones}"
    cidr                   = "${var.vpc_cidr}"
    enable_nat_gateway     = true
    name                   = "${var.vpc_name}"
    private_subnets        = "${var.vpc_private_subnets}"
    public_subnets         = "${var.vpc_public_subnets}"
    one_nat_gateway_per_az = true
    single_nat_gateway     = false
    tags                   = {
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}
