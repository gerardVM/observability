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

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::${local.config.permissions_setup.aws_account_id}:role/${local.config.permissions_setup.aws_assume_role}"
    session_name = "observability"
  }
}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.grafana_cloud_api_key
}

provider "grafana" {
  alias = "stack_0"
  url   = local.config.organization.stacks[0].url
  auth  = grafana_cloud_stack_service_account_token.sa_token[local.config.permissions_setup.stack_key].key
}

provider "grafana" {
  alias                       = "cloud_provider_integration"
  cloud_provider_url          = "https://connections-api-prod-us-east-0.grafana.net"
  cloud_provider_access_token = grafana_cloud_access_policy_token.ap_token[local.config.permissions_setup.cloud_integration_token].token
}

variable "grafana_cloud_api_key" {
  type = string
}
