locals {
  access_policies = local.config.organization.access_policies

  ap_tokens = flatten([
    for ap_key, ap_value in local.access_policies : [
      for token in ap_value.tokens : {
        access_policy = ap_key
        name          = token.name
        expires_at    = try(token.expires_at, null)
  }]])
}


resource "grafana_cloud_access_policy" "access_policy" {
  for_each = local.access_policies

  name         = each.key
  display_name = each.key
  scopes       = each.value.scopes
  region       = each.value.realm == "organization" ? local.config.organization.region : grafana_cloud_stack.stack[each.value.realm].region_slug

  realm {
    type       = each.value.realm == "organization" ? "org" : "stack"
    identifier = each.value.realm == "organization" ? data.grafana_cloud_organization.current.id : grafana_cloud_stack.stack[each.value.realm].id

    dynamic "label_policy" {
      for_each = { for policy in try(each.value.label_policies, []) : policy.key => policy }

      content {
        selector = label_policy.value.value # Temporary patch
      }

    }
  }

  provider = grafana.cloud
}

resource "grafana_cloud_access_policy_token" "ap_token" {
  for_each = { for token in local.ap_tokens : "${token.access_policy}-${token.name}" => token }

  region           = grafana_cloud_access_policy.access_policy["${each.value.access_policy}"].region
  access_policy_id = grafana_cloud_access_policy.access_policy["${each.value.access_policy}"].policy_id
  name             = each.value.name
  display_name     = each.value.name
  expires_at       = each.value.expires_at

  provider = grafana.cloud
}