locals {
  stacks = local.config.organization.stacks

  service_accounts = flatten([
    for key, value in local.stacks : [
      for service_account in value.service_accounts : {
        stack    = key
        name     = service_account.name
        role     = service_account.role
        disabled = service_account.disabled
        tokens   = service_account.tokens
  }]])

  sa_tokens = flatten([
    for service_account in local.service_accounts : [
      for token in service_account.tokens : {
        stack           = service_account.stack
        service_account = service_account.name
        name            = token.name
  }]])
}


resource "grafana_cloud_stack" "stack" {
  for_each = local.stacks

  name        = "${each.key}.grafana.net"
  slug        = each.key
  region_slug = "prod-us-east-0"

  provider = grafana.cloud
}

resource "grafana_cloud_stack_service_account" "stack_sa" {
  for_each = { for sa in local.service_accounts : "${sa.stack}-${sa.name}" => sa }

  stack_slug  = grafana_cloud_stack.stack[each.value.stack].slug
  name        = each.value.name
  role        = each.value.role
  is_disabled = each.value.disabled

  provider = grafana.cloud
}

resource "grafana_cloud_stack_service_account_token" "sa_token" {
  for_each = { for token in local.sa_tokens : "${token.stack}-${token.service_account}-${token.name}" => token }

  stack_slug         = grafana_cloud_stack.stack[each.value.stack].slug
  name               = each.value.name
  service_account_id = grafana_cloud_stack_service_account.stack_sa["${each.value.stack}-${each.value.service_account}"].id

  provider = grafana.cloud
}