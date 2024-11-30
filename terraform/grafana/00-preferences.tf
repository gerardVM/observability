terraform {
  required_version = "1.9.5"

  backend "s3" {
    bucket  = "projects-terraform-states"
    key     = "observability.tfstate"
    region  = "eu-west-3"
    encrypt = true
    assume_role = {
      role_arn     = "arn:aws:iam::877759700856:role/provisioner"
      session_name = "observability_repository"
    }
  }
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.13.1"
    }
  }
}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.grafana_cloud_api_key
}

provider "grafana" {
  alias = "stack"
  url   = local.config.organization.url
  auth  = grafana_cloud_stack_service_account_token.sa_token["gerardvm-admin-admin_key"].key
}

provider "grafana" {
  alias                       = "cloud_provider_integration"
  url                         = local.config.organization.url                                                       # Grafana instance URL
  auth                        = grafana_cloud_stack_service_account_token.sa_token["gerardvm-admin-admin_key"].key  # Standard Grafana API Key
  cloud_provider_url          = "https://connections-api-prod-us-east-0.grafana.net"                                # URL for the Grafana Cloud Provider API
  cloud_provider_access_token = grafana_cloud_access_policy_token.ap_token["integrations-integrations_token"].token # aws_integration token
}

variable "grafana_cloud_api_key" {
  type = string
}
