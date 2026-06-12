output "argocd_namespace" {
  value = kubernetes_namespace.infra_tools.metadata[0].name
}