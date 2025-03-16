# # Automatic import of Dashboards

# import {
#   for_each = { for dashboard in local.dashboards : "${dashboard.folder}-${dashboard.name}" => dashboard if try(dashboard.definition.uid, null) != null }

#   to = grafana_dashboard.dashboard["${each.value.folder}-${each.value.name}"]
#   id = each.value.definition.uid
# }


# # Automatic import of Alert Rules

# import {
#   for_each = { for rule in local.alerting_evaluations : "${rule.folder}-${rule.name}" => rule if try(rule.definition.imported, false) }

#   to = grafana_rule_group.alert_rules["${each.value.folder}-${each.value.name}"]
#   id = "${grafana_folder.teams[each.value.folder].uid}:${each.value.name}"
# }
