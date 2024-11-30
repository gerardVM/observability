resource "aws_iam_role" "grafana_cloud" {
  name = "grafana_cloud"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${local.config.grafana_cloud_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.config.grafana_cloud_external_id
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_integration" {
  name = "cloudwatch_integration"
  role = aws_iam_role.grafana_cloud.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "tag:GetResources",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "apigateway:GET",
          "aps:ListWorkspaces",
          "autoscaling:DescribeAutoScalingGroups",
          "dms:DescribeReplicationInstances",
          "dms:DescribeReplicationTasks",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeSpotFleetRequests",
          "shield:ListProtections",
          "storagegateway:ListGateways",
          "storagegateway:ListTagsForResource"
        ]
        Effect    = "Allow"
        Resource  = "*"
      },
    ]
  })
}
