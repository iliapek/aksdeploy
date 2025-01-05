output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "aks_kubeconfig" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].raw_kube_config
}
