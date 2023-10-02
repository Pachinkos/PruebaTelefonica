variable "acr_server" {
  type        = string
}

variable "acr_server_subscription" {
  type        = string
}

variable "source_acr_client_id" {
  type        = string
}

variable "source_acr_client_secret" {
  type        = string
}

variable "source_acr_server" {
  type        = string
}

variable "charts" {
  type = list(object({
    chart_name       = string
    chart_namespace  = string
    chart_repository = string
    chart_version    = string
    values = list(object({
      name  = string
      value = any
    }))
    sensitive_values = list(object({
      name  = string
      value = any
    }))
  }))
}