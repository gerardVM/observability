locals {
  directories = {
    owners = "../../setups/owners"
  }
}


resource "grafana_folder" "teams" {
  for_each = local.directories
  provider = grafana.stack

  title                        = each.key
  prevent_destroy_if_not_empty = true
}
