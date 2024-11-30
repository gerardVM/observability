data "grafana_cloud_organization" "current" {
  slug = local.config.organization.slug

  provider = grafana.cloud
}