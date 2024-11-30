resource "grafana_cloud_provider_aws_account" "provider" { # Registers an AWS account with Grafana Cloud to allow Grafana to assume a role within the AWS account.
  for_each = local.stacks.gerardvm.aws_integration_accounts
  stack_id = grafana_cloud_stack.stack["gerardvm"].id
  role_arn = aws_iam_role.grafana_cloud.arn
  regions  = ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-west-1", "eu-west-2", "eu-west-3"]

  provider = grafana.cloud_provider_integration
}

resource "grafana_cloud_provider_aws_cloudwatch_scrape_job" "cw_scrape_job" { # Creates a scrape job in Grafana Cloud to scrape metrics from AWS CloudWatch.
  for_each                = local.stacks.gerardvm.aws_integration_accounts
  stack_id                = grafana_cloud_stack.stack["gerardvm"].id
  name                    = each.key
  aws_account_resource_id = grafana_cloud_provider_aws_account.provider[each.key].resource_id
  export_tags             = true

  dynamic "service" {
    for_each = local.scrape_jobs

    content {
      name = service.key

      dynamic "metric" {
        for_each = service.value

        content {
          name       = metric.key
          statistics = metric.value
        }
      }

      scrape_interval_seconds = 300
    }

  }

  provider = grafana.cloud_provider_integration
}