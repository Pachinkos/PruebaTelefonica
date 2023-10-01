variable "acr_server" {
  description = "Azure Container Registry Server"
  type = string
}

variable "acr_server_subscription" {
  description = "Azure Container Registry Subscription ID"
  type = string
}

variable "source_acr_client_id" {
  description = "Client ID for the source Azure Container Registry"
  type = string
}

variable "source_acr_client_secret" {
  description = "Client Secret for the source Azure Container Registry"
  type = string
}

variable "source_acr_server" {
  description = "Server URL for the source Azure Container Registry"
  type = string
}

variable "charts" {
  description = "List of Helm charts to deploy"
  type = list(object({
    chart_name = string
    chart_namespace = string
    chart_repository = string
    chart_version = string
    values = list(object({
      name = string
      value = any
    }))
    sensitive_values = list(object({
      name = string
      value = any
    }))
  }))
}