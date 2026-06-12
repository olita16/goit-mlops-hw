
resource "kubernetes_namespace" "infra_tools" {
  metadata {
    name = "infra-tools"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = var.namespace

  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  depends_on = [kubernetes_namespace.infra_tools]
}

