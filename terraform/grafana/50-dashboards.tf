locals {
  dashboards = flatten([
    for folder_key, folder_value in local.directories : [
      for file in fileset("${folder_value}/dashboards", "*.json") : {
        folder     = folder_key
        name       = replace(file, ".json", "")
        definition = jsondecode(file("${folder_value}/dashboards/${file}"))
  }]])
}

resource "grafana_dashboard" "dashboard" {
  for_each = { for dashboard in local.dashboards : "${dashboard.folder}-${dashboard.name}" => dashboard }
  provider = grafana.stack

  folder      = grafana_folder.teams[each.value.folder].uid
  config_json = jsonencode(merge({ "title" = each.value.name }, each.value.definition))
}
