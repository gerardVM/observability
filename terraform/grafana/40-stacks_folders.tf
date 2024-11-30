locals {
  directories = toset([ for path in fileset("../../setups", "**") : split("/", path)[0] ])
}

resource "grafana_folder" "teams" {
  for_each = local.directories
  provider = grafana.stack

  title                        = each.value
  prevent_destroy_if_not_empty = true
}
