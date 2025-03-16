locals {
  dashboards = flatten([
    for folder in local.directories : [
      for file in fileset("../../setups/${folder}/dashboards", "*.json") : {
        folder     = folder
        name       = replace(file, ".json", "")
        definition = jsondecode(file("../../setups/${folder}/dashboards/${file}"))
  }]])
}

resource "grafana_dashboard" "dashboard" {
  for_each = { for dashboard in local.dashboards : "${dashboard.folder}-${dashboard.name}" => dashboard }
  provider = grafana.stack_0

  folder      = grafana_folder.teams[each.value.folder].uid
  config_json = jsonencode(merge({ "title" = each.value.name }, each.value.definition))
}
