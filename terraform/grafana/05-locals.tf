locals {
  config = yamldecode(file("${path.module}/config.yaml"))

  seconds = tomap({
    "s" = 1,
    "m" = 60,
    "h" = 3600,
  })
}