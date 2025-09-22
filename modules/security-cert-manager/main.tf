resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      secretName = var.secret_name
      commonName = var.common_name
      dnsNames   = var.dns_names

      issuerRef = {
        name = var.issuer_name
        kind = var.issuer_kind
      }
    }
  }
}
