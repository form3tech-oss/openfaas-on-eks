# openfaas-on-eks
An experiment with OpenFaaS on EKS.

## Introduction

This Terraform project automates the deployment of [OpenFaaS](https://www.openfaas.com/) on top of an [EKS](https://aws.amazon.com/eks/) cluster.

## Prerequisites

* Terraform v0.12.0 (or later).

## What's included

* Creation of a new VPC for the EKS cluster with the required [tags](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).
* Creation of public and private subnets for the EKS cluster with the required [tags](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).
* Creation of the EKS cluster (with a single worker group).
* Deployment of OpenFaaS using [Helm](https://helm.sh/).
* Exposure of the OpenFaaS gateway using TLS certificates obtained from [Let's Encrypt](https://letsencrypt.org/) using [`cert-manager`](https://github.com/jetstack/cert-manager).

## Running

You must start by configuring the [AWS Terraform provider](https://www.terraform.io/docs/providers/aws/index.html).
The easiest way to do this is probably by setting the following environment variables using adequate values:

```shell
$ export AWS_ACCESS_KEY_ID="(...)"
$ export AWS_SECRET_ACCESS_KEY="(...)"
$ export AWS_REGION="(...)"
```

Then, you must create a `secrets.tfvars` file in the root of the repository.
This file should contain adequate values for (at least) the following variables:

```hcl
eks_cluster_name  = "eks-1"
letsencrypt_email = "alice@example.com"
openfaas_host     = "openfaas.example.com"
openfaas_password = "(...)"
vpc_name          = "eks-1"
```

If you want to customize any other variable (e.g. `openfaas_clusterissuer_name`), you can do so in this file as well.
Once you are happy with the values, simply run the following command to bootstrap OpenFaaS on top of EKS:

```shell
$ terraform apply -var-file secret.tfvars
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| `eks_cluster_name` | The name of the EKS cluster. | `string` | N/A | Yes |
| `eks_cluster_version` | The version of the EKS cluster. | `string` | `1.13` | No |
| `eks_wg_1_instance_type` | The type of instances to use when provisioning the initial worker group. | `string` | `m5.large` | No |
| `eks_wg_1_size` | The number of worker nodes on the initial worker group. | `string` | `2` | No |
| `letsencrypt_email` | The email address to use when creating the Let's Encrypt `ClusterIssuer` resources. | `string` | N/A | Yes |
| `openfaas_clusterissuer_name` | The name of the `ClusterIssuer` resource to use for provisioning the certificate used by the OpenFaaS ingress. | `string` | `letsencrypt-staging` | No |
| `openfaas_host` | The host at which OpenFaaS will be exposed (**NOTE:** DNS must be configured separately). | `string` | N/A | Yes |
| `openfaas_username` | The username to use for OpenFaaS. | `string` | `admin` | No |
| `openfaas_password` | The password to use for OpenFaaS. | `string` | N/A | Yes |
| `vpc_cidr` | The CIDR block for the VPC. | `string` | `10.30.0.0/16` | No |
| `vpc_name` | The name of the VPC. | `string` | N/A | Yes |
| `vpc_availability_zones` | List of availability zones within a single region. | `list` | `["eu-west-1a", "eu-west-1b", "eu-west-1c"]` | No |
| `vpc_private_subnets` | List of private subnet CIDRs within the VPC. | `list` | `["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]` | No |
| `vpc_public_subnets` | List of public subnet CIDRs within the VPC. | `list` | `["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]` | No |
