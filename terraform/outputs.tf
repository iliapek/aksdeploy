output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_url" {
  value = azurerm_container_registry.acr.login_server
}
