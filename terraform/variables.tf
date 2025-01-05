variable "location" {
  description = "The Azure Region to deploy resources"
  default     = "East US"
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  default     = "Iliasacr"
}
