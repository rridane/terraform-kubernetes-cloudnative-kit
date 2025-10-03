locals {
  # Helpers
  receivers_files = fileset(var.receivers_dir, "*.y*ml")
  processors_files = fileset(var.processors_dir, "*.y*ml")
  exporters_files = fileset(var.exporters_dir, "*.y*ml")
  connectors_files = fileset(var.connectors_dir, "*.y*ml")

  receivers  = length(local.receivers_files)  > 0 ?
    merge([for f in local.receivers_files : yamldecode(file("${var.receivers_dir}/${f}"))]...) : {}
  processors = length(local.processors_files) > 0 ?
    merge([for f in local.processors_files : yamldecode(file("${var.processors_dir}/${f}"))]...) : {}
  exporters  = length(local.exporters_files)  > 0 ?
    merge([for f in local.exporters_files : yamldecode(file("${var.exporters_dir}/${f}"))]...) : {}
  connectors = length(local.connectors_files) > 0 ?
    merge([for f in local.connectors_files : yamldecode(file("${var.connectors_dir}/${f}"))]...) : {}

  # Config collector finale
  otel_config = {
    receivers  = local.receivers
    processors = local.processors
    exporters  = local.exporters
    connectors = local.connectors

    service = {
      pipelines = {
        traces = {
          receivers  = [for k, _ in local.receivers  : k]
          processors = [for k, _ in local.processors : k]
          exporters  = [for k, _ in local.exporters  : k]
        }
      }
    }
  }
  otel_config_yaml = yamlencode(local.otel_config)
}

resource "kubernetes_manifest" "otel_collector" {
  manifest = {
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "OpenTelemetryCollector"
    metadata = {
      namespace = var.namespace
      name      = "otelcol"
      labels    = var.labels
    }
    spec = {
      mode           = var.mode
      replicas       = var.replicas
      serviceAccount = var.serviceAccountName
      args           = tolist(var.extra_args)

      # Config finale encodée en YAML multi-ligne, indentée pour lisibilité
      config = <<-EOT
${indent(6, local.otel_config_yaml)}
EOT
    }
  }
}
