provider "helm" {
    kubernetes {
        config_path = "${module.eks.kubeconfig_filename}"
    }
    service_account = "tiller"
    tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.14.1"
}

provider "kubernetes" {
    config_path = "${module.eks.kubeconfig_filename}"
}

resource "kubernetes_service_account" "tiller" {
    metadata {
        name      = "tiller"
        namespace = "kube-system"
    }
}

resource "kubernetes_cluster_role_binding" "tiller" {
     metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "cluster-admin"
    }
    subject {
        api_group = ""
        kind      = "ServiceAccount"
        name      = "${kubernetes_service_account.tiller.metadata.0.name}"
        namespace = "${kubernetes_service_account.tiller.metadata.0.namespace}"
    }
}

resource "kubernetes_namespace" "openfaas" {
    metadata {
        name = "openfaas"
    }
}

resource "kubernetes_namespace" "openfaas-fn" {
    metadata {
        name = "openfaas-fn"
    }
}

resource "kubernetes_secret" "openfaas" {
    metadata {
        name      = "basic-auth"
        namespace = "${kubernetes_namespace.openfaas.metadata.0.name}"
    }
    data = {
        basic-auth-user     = "${var.openfaas_username}"
        basic-auth-password = "${var.openfaas_password}"
    }
}

data "helm_repository" "openfaas" {
    name = "openfaas"
    url  = "https://openfaas.github.io/faas-netes/"
}


resource "helm_release" "openfaas" {
    depends_on = [
        "kubernetes_cluster_role_binding.tiller",
    ]

    chart      = "openfaas"
    name       = "openfaas"
    namespace  = "${kubernetes_namespace.openfaas.metadata.0.name}"
    repository = "${data.helm_repository.openfaas.metadata.0.name}"

    set {
        name  = "basic_auth"
        value = "true"
    }

    set {
        name = "functionNamespace"
        value = "openfaas-fn"
    }
}

resource "null_resource" "cert-manager-prereqs" {
    provisioner "local-exec" {
        command = <<EOF
for f in 00-crds.yaml 01-namespace.yaml; do
    kubectl --kubeconfig "${module.eks.kubeconfig_filename}" apply -f "https://raw.githubusercontent.com/jetstack/cert-manager/v0.8.1/deploy/manifests/$f"
done
EOF
    }

    provisioner "local-exec" {
        command = <<EOF
for f in 00-crds.yaml 01-namespace.yaml; do
    kubectl --kubeconfig "${module.eks.kubeconfig_filename}" delete --ignore-not-found -f "https://raw.githubusercontent.com/jetstack/cert-manager/v0.8.1/deploy/manifests/$f"
done
EOF
        when    = "destroy"
    }
}

data "helm_repository" "cert-manager" {
    name = "cert-manager"
    url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert-manager" {
    depends_on = [
        "null_resource.cert-manager-prereqs",
        "kubernetes_cluster_role_binding.tiller",
    ]

    chart      = "cert-manager"
    name       = "cert-manager"
    namespace  = "cert-manager"
    repository = "${data.helm_repository.cert-manager.metadata.0.name}"
}

resource "null_resource" "letsencrypt-clusterissuers" {
    depends_on = [
        "helm_release.cert-manager",
    ]

    provisioner "local-exec" {
        command = <<EOF
cat <<EOT | kubectl --kubeconfig "${module.eks.kubeconfig_filename}" apply -f -
${templatefile(
    "${path.module}/templates/letsencrypt-clusterissuers.yaml.tmpl",
    {
        letsencrypt_email = "${var.letsencrypt_email}",
    }
)}
EOT
EOF
    }

    provisioner "local-exec" {
        command = <<EOF
cat <<EOT | kubectl --kubeconfig "${module.eks.kubeconfig_filename}" delete --ignore-not-found -f -
${templatefile(
    "${path.module}/templates/letsencrypt-clusterissuers.yaml.tmpl",
    {
        letsencrypt_email = "${var.letsencrypt_email}",
    }
)}
EOT
EOF
        when    = "destroy"
    }
}

resource "kubernetes_namespace" "nginx-ingress" {
    metadata {
        name = "nginx-ingress"
    }
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "nginx-ingress" {
    depends_on = [
        "kubernetes_cluster_role_binding.tiller",
    ]

    chart      = "nginx-ingress"
    name       = "nginx-ingress"
    namespace  = "${kubernetes_namespace.nginx-ingress.metadata.0.name}"
    repository = "${data.helm_repository.stable.metadata.0.name}"

    set {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "nlb"
    }

    set {
        name  = "controller.service.externalTrafficPolicy"
        value = "Local"
    }

    set {
        name  = "controller.replicaCount"
        value = "2"
    }
}

resource "null_resource" "openfaas-ingress" {
    depends_on = [
        "null_resource.letsencrypt-clusterissuers",
        "helm_release.nginx-ingress",
    ]

    provisioner "local-exec" {
        command = <<EOF
cat <<EOT | kubectl --kubeconfig "${module.eks.kubeconfig_filename}" apply -f -
${templatefile(
    "${path.module}/templates/openfaas-ingress.yaml.tmpl",
    {
        openfaas_clusterissuer_name = "${var.openfaas_clusterissuer_name}",
        openfaas_host               = "${var.openfaas_host}",
    }
)}
EOT
EOF
    }

    provisioner "local-exec" {
        command = <<EOF
cat <<EOT | kubectl --kubeconfig "${module.eks.kubeconfig_filename}" delete --ignore-not-found -f -
${templatefile(
    "${path.module}/templates/openfaas-ingress.yaml.tmpl",
    {
        openfaas_clusterissuer_name = "${var.openfaas_clusterissuer_name}",
        openfaas_host               = "${var.openfaas_host}",
    }
)}
EOT
EOF
        when    = "destroy"
    }
}
