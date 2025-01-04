provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-cluster"
  location = "East US"
}

resource "azurerm_container_registry" "acr" {
  name                = "mycontainerregistry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaks"
  
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    availability_zones = ["1", "2", "3"]
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }

  private_cluster {
    enable_private_cluster = true
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_kubernetes_cluster_extension" "ingress_controller" {
  name                 = "nginx-ingress-controller"
  cluster_name         = azurerm_kubernetes_cluster.aks.name
  resource_group_name  = azurerm_resource_group.rg.name
  extension_type       = "Kubernetes"
  publisher             = "Microsoft.Azure.Extensions"
  type                  = "CustomScript"
  settings = <<SETTINGS
{
    "script": "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml"
}
SETTINGS
}

