output "otel_config_yaml" {
  description = "Config complète générée pour l'OpenTelemetry Collector"
  value       = local.otel_config_yaml
}

output "otel_collector_manifest" {
  description = "Manifeste CRD OpenTelemetryCollector complet"
  value       = yamlencode(kubernetes_manifest.otel_collector.manifest)
}
