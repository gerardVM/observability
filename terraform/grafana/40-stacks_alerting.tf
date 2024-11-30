locals {
  alerting_evaluations = flatten([
    for folder in local.directories : [
      for file in fileset("../../setups/${folder}/alerting/evaluations", "*.yaml") : {
        folder     = folder
        name       = replace(file, ".yaml", "")
        definition = yamldecode(file("../../setups/${folder}/alerting/evaluations/${file}")).groups[0] # This setup enables support for unmodified Grafana import files
  }]])

  alerting_contact_points = flatten([
    for folder in local.directories : [
      for contact_point in yamldecode(file("../../setups/${folder}/alerting/contacts.yaml")).contactPoints : { # This setup enables support for unmodified Grafana import files
        folder     = folder
        name       = contact_point.name
        definition = contact_point.receivers
  }]])
}


resource "grafana_rule_group" "alert_rules" {
  for_each = { for rule in local.alerting_evaluations : "${rule.folder}-${rule.name}" => rule }
  provider = grafana.stack

  folder_uid         = grafana_folder.teams[each.value.folder].uid
  disable_provenance = true # Deny modifying the rule group from other sources than Terraform or the Grafana API
  name               = each.value.name
  interval_seconds   = tonumber(regex("^\\d+", each.value.definition.interval)) * lookup(local.seconds, regex("\\D+$", each.value.definition.interval))
  # org_id             = 1

  dynamic "rule" {
    for_each = each.value.definition.rules

    content {
      name           = rule.value.title
      for            = rule.value.for
      condition      = rule.value.condition
      no_data_state  = try(rule.value.noDataState, "NoData")
      exec_err_state = rule.value.execErrState
      annotations    = try(rule.value.annotations, {})
      labels         = try(rule.value.labels, {})
      is_paused      = try(rule.value.isPaused, false)

      dynamic "data" {
        for_each = rule.value.data

        content {
          ref_id     = data.value.refId
          query_type = try(data.value.queryType, "")
          relative_time_range {
            from = try(data.value.relativeTimeRange.from, 0)
            to   = try(data.value.relativeTimeRange.to, 0)
          }
          datasource_uid = data.value.datasourceUid
          model          = jsonencode(data.value.model)
        }
      }

      dynamic "notification_settings" {
        for_each = try(rule.value.notification_settings != null, false) ? [rule.value.notification_settings] : []

        content {
          contact_point   = notification_settings.value.receiver
          group_by        = try(notification_settings.value.groupBy, [])
          group_interval  = try(notification_settings.value.groupInterval, null)
          group_wait      = try(notification_settings.value.groupWait, null)
          mute_timings    = try(notification_settings.value.muteTimings, [])
          repeat_interval = try(notification_settings.value.repeatInterval, null)
        }
      }
    }
  }
}

resource "grafana_contact_point" "contact_point" {
  for_each = { for contact_point in local.alerting_contact_points : contact_point.name => contact_point }
  provider = grafana.stack

  name               = each.value.name
  disable_provenance = true # Deny modifying the contact point from other sources than Terraform or the Grafana API

  // TODO: Add support for other types of contact points
  dynamic "email" {
    for_each = { for receiver in each.value.definition : "${receiver.type}-${receiver.settings.addresses}" => receiver if receiver.type == "email" }

    content {
      addresses               = [email.value.settings.addresses] # Setup file expects comma separated string
      message                 = email.value.settings.message
      subject                 = email.value.settings.subject
      single_email            = email.value.settings.singleEmail
      disable_resolve_message = email.value.disableResolveMessage
    }
  }
}