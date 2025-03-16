locals {
  aws_integration_accounts = flatten([
    for stack in local.stacks : [
      for integration_account in stack.aws_integration_accounts : {
        stack   = stack.name
        name    = integration_account.name
        id      = integration_account.id
        regions = integration_account.regions
  }]])
}

resource "grafana_cloud_provider_aws_account" "provider" {
  for_each = { for account in local.aws_integration_accounts : account.name => account }

  stack_id = grafana_cloud_stack.stack[each.value.stack].id
  role_arn = aws_iam_role.grafana_cloud.arn
  regions  = each.value.regions

  provider = grafana.cloud_provider_integration
}

resource "grafana_cloud_provider_aws_cloudwatch_scrape_job" "cw_scrape_job" {
  for_each = { for account in local.aws_integration_accounts : account.name => account }

  stack_id                = grafana_cloud_stack.stack[each.value.stack].id
  name                    = each.key
  enabled                 = true
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


locals {
  scrape_jobs = {
    "AWS/ApiGateway" = {
      "4xx"                = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "5xx"                = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Count"              = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "IntegrationLatency" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Latency"            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "4XXError"           = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "5XXError"           = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "CacheHitCount"      = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "CacheMissCount"     = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ClientError"        = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConnectCount"       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "DataProcessed"      = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ExecutionError"     = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "IntegrationError"   = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "MessageCount"       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/Billing" = {
      "EstimatedCharges" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/SQS" = {
      "ApproximateAgeOfOldestMessage"         = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ApproximateNumberOfMessagesDelayed"    = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ApproximateNumberOfMessagesNotVisible" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ApproximateNumberOfMessagesVisible"    = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "NumberOfEmptyReceives"                 = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "NumberOfMessagesDeleted"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "NumberOfMessagesReceived"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "NumberOfMessagesSent"                  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "SentMessageSize"                       = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/Lambda" = {
      "Invocations"                                = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Errors"                                     = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Throttles"                                  = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Duration"                                   = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AsyncEventAge"                              = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AsyncEventsDropped"                         = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AsyncEventsReceived"                        = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ClaimedAccountConcurrency"                  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConcurrentExecutions"                       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "DeadLetterErrors"                           = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "DestinationDeliveryFailures"                = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "IteratorAge"                                = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OffsetLag"                                  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OversizedRecordCount"                       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PostRuntimeExtensionsDuration"              = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedConcurrencyInvocations"          = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedConcurrencySpilloverInvocations" = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedConcurrencyUtilization"          = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedConcurrentExecutions"            = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "RecursiveInvocationsDropped"                = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "UnreservedConcurrentExecutions"             = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/SES" = {
      "Bounce"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Complaint"                = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Delivery"                 = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Reject"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Send"                     = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Clicks"                   = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Opens"                    = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Rendering Failures"       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Reputation.BounceRate"    = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Reputation.ComplaintRate" = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    # "AWS/Scheduler" = {
    #   "InvocationAttemptCount"                                         = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "InvocationDroppedCount"                                         = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "InvocationThrottleCount"                                        = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "InvocationsFailedToBeSentToDeadLetterCount"                     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "InvocationsSentToDeadLetterCount"                               = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "InvocationsSentToDeadLetterCount_Truncated_MessageSizeExceeded" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TargetErrorCount"                                               = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TargetErrorThrottledCount"                                      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }
    # "AWS/Cognito" = {
    #   "AccountTakeOverRisk"        = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "CompromisedCredentialsRisk" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FederationSuccesses"        = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FederationThrottles"        = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "NoRisk"                     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "OverrideBlock"              = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "Risk"                       = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SignInSuccesses"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SignInThrottles"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SignUpSuccesses"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SignUpThrottles"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TokenRefreshSuccesses"      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TokenRefreshThrottles"      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }
    # "AWS/CloudFront" = {
    #   "4xxErrorRate"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "5xxErrorRate"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BytesDownloaded"            = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BytesUploaded"              = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "Requests"                   = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TotalErrorRate"             = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "401ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "403ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "404ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "502ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "503ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "504ErrorRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "CacheHitRate"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FunctionComputeUtilization" = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FunctionExecutionErrors"    = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FunctionInvocations"        = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FunctionThrottles"          = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FunctionValidationErrors"   = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaExecutionError"       = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaLimitExceededErrors"  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaValidationError"      = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "OriginLatency"              = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }
    # "AWS/Logs" = {
    #   "DeliveryErrors"     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "DeliveryThrottling" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ForwardedBytes"     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ForwardedLogEvents" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "IncomingBytes"      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "IncomingLogEvents"  = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }
    # "AWS/S3" = {
    #   "NumberOfObjects"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BucketSizeBytes"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "AllRequests"                  = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "4xxErrors"                    = ["Sum"] # ["Sum", "Maximum", "Minimum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "TotalRequestLatency"          = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "5xxErrors"                    = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BytesDownloaded"              = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BytesPendingReplication"      = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "BytesUploaded"                = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "DeleteRequests"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "FirstByteLatency"             = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "GetRequests"                  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "HeadRequests"                 = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ListRequests"                 = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "OperationsFailedReplication"  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "OperationsPendingReplication" = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "PostRequests"                 = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "PutRequests"                  = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ReplicationLatency"           = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SelectRequests"               = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SelectReturnedBytes"          = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "SelectScannedBytes"           = ["Maximum"] # ["Maximum", "Minimum", "Sum", "Average", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }
    "AWS/Route53" = {
      "ChildHealthCheckHealthyCount" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConnectionTime"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "DNSQueries"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "HealthCheckPercentageHealthy" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "HealthCheckStatus"            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "SSLHandshakeTime"             = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "TimeToFirstByte"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/Events" = {
      "DeadLetterInvocations"                     = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Events"                                    = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "FailedInvocations"                         = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "IngestiontoInvocationCompleteLatency"      = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "IngestiontoInvocationStartLatency"         = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "InvocationAttempts"                        = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "Invocations"                               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "InvocationsCreated"                        = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "InvocationsFailedToBeSentToDlq"            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "InvocationsSentToDlq"                      = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "MatchedEvents"                             = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsApproximateCallCount"             = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsApproximateFailedCount"           = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsApproximateSuccessCount"          = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsApproximateThrottledCount"        = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsEntriesCount"                     = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsFailedEntriesCount"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsLatency"                          = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutEventsRequestSize"                      = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsApproximateCallCount"      = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsApproximateFailedCount"    = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsApproximateSuccessCount"   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsApproximateThrottledCount" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsEntriesCount"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsFailedEntriesCount"        = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PutPartnerEventsLatency"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "RetryInvocationAttempts"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "SuccessfulInvocationAttempts"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ThrottledRules"                            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "TriggeredRules"                            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    "AWS/DynamoDB" = {
      "AccountMaxReads"                             = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AccountMaxTableLevelReads"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AccountMaxTableLevelWrites"                  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AccountMaxWrites"                            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AccountProvisionedReadCapacityUtilization"   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AccountProvisionedWriteCapacityUtilization"  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "AgeOfOldestUnreplicatedRecord"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConditionalCheckFailedRequests"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConsumedChangeDataCaptureUnits"              = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConsumedReadCapacityUnits"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ConsumedWriteCapacityUnits"                  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "FailedToReplicateRecordCount"                = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "MaxProvisionedTableReadCapacityUtilization"  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "MaxProvisionedTableWriteCapacityUtilization" = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OnDemandMaxReadRequestUnits"                 = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OnDemandMaxWriteRequestUnits"                = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OnlineIndexConsumedWriteCapacity"            = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OnlineIndexPercentageProgress"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "OnlineIndexThrottleEvents"                   = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "PendingReplicationCount"                     = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedReadCapacityUnits"                = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ProvisionedWriteCapacityUnits"               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ReadThrottleEvents"                          = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ReplicationLatency"                          = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ReturnedBytes"                               = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ReturnedItemCount"                           = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ReturnedRecordsCount"                        = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "SuccessfulRequestLatency"                    = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "SystemErrors"                                = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ThrottledPutRecordCount"                     = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "ThrottledRequests"                           = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "TimeToLiveDeletedItemCount"                  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "TransactionConflict"                         = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "UserErrors"                                  = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
      "WriteThrottleEvents"                         = ["Average"] # ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    }
    # "AWS/States" = {
    #   "ActivitiesFailed"               = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivitiesHeartbeatTimedOut"    = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivitiesScheduled"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivitiesStarted"              = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivitiesSucceeded"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivitiesTimedOut"             = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivityRunTime"                = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivityScheduleTime"           = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ActivityTime"                   = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ConsumedCapacity"               = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionThrottled"             = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionTime"                  = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionsAborted"              = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionsFailed"               = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionsStarted"              = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionsSucceeded"            = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExecutionsTimedOut"             = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExpressExecutionBilledDuration" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExpressExecutionBilledMemory"   = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ExpressExecutionMemory"         = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionRunTime"          = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionScheduleTime"     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionTime"             = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionsFailed"          = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionsScheduled"       = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionsStarted"         = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionsSucceeded"       = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "LambdaFunctionsTimedOut"        = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ProvisionedBucketSize"          = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ProvisionedRefillRate"          = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationRunTime"      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationScheduleTime" = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationTime"         = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationsFailed"      = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationsScheduled"   = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationsStarted"     = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationsSucceeded"   = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ServiceIntegrationsTimedOut"    = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    #   "ThrottledEvents"                = ["Average", "Maximum", "Minimum", "Sum", "SampleCount", "p50", "p75", "p90", "p95", "p99"]
    # }

  }
}