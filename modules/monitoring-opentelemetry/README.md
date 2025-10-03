# 🚀 Module Terraform — OpenTelemetry Collector Generator

Ce module permet de **générer et déployer automatiquement** une ressource
`OpenTelemetryCollector` (CRD de l’OpenTelemetry Operator) à partir de fragments
de configuration organisés dans des dossiers dédiés (`receivers/`, `processors/`, `exporters/`, `connectors/`).

## 📂 Structure recommandée

Nous conseillons d’organiser vos fragments de configuration dans un répertoire **`otel.conf.d/`** afin de séparer proprement les familles de composants :  

```text
otel.conf.d/
├── receivers/
│   └── otlp.yaml
├── processors/
│   └── batch.yaml
├── exporters/
│   └── logging.yaml
└── connectors/
```

Chaque fichier contient la définition d’un composant unique, avec une **clé racine** correspondant à son nom.

## Exemples de fichiers

**`otel.conf.d/receivers/otlp.yaml`**
```yaml
otlp:
  protocols:
    grpc: {}
    http: {}
```

**`otel.conf.d/processors/batch.yaml`**
```yaml
batch:
  timeout: 5s
  send_batch_size: 1000
```

**`otel.conf.d/exporters/logging.yaml`**
```yaml
logging:
  loglevel: debug
```

**`otel.conf.d/connectors/`**
```text
(dossier vide ou fichiers de connecteurs si nécessaires)
```

## 🛠️ Exemple d’utilisation

```hcl
module "otel_collector" {
  source = "./modules/otel-collector"

  namespace          = "observability"
  receivers_dir      = "./receivers"
  processors_dir     = "./processors"
  exporters_dir      = "./exporters"
  connectors_dir     = "./connectors"

  replicas           = 3
  serviceAccountName = "otel-collector"
  labels             = { app = "observability" }
  mode               = "deployment"

  extra_args = [
    "--feature-gates=filelog.allowHeaderMetadataParsing"
  ]
}
```

## 📜 Exemple rendu final

Le module assemble automatiquement les fragments pour produire un CRD `OpenTelemetryCollector` :

```yaml
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  namespace: observability
  name: otelcol
  labels:
    app: observability
spec:
  mode: deployment
  replicas: 3
  serviceAccount: otel-collector
  args: []
  config: |
      receivers:
        otlp:
          protocols:
            grpc: {}
            http: {}
      processors:
        batch:
          timeout: 5s
          send_batch_size: 1000
      exporters:
        logging:
          loglevel: debug
      connectors: {}
      service:
        pipelines:
          traces:
            receivers:
              - otlp
            processors:
              - batch
            exporters:
              - logging
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connectors_dir"></a> [connectors\_dir](#input\_connectors\_dir) | Dossier ou trouver les fichiers connectors | `string` | n/a | yes |
| <a name="input_exporters_dir"></a> [exporters\_dir](#input\_exporters\_dir) | Dossier ou trouver les fichiers exporters | `string` | n/a | yes |
| <a name="input_extra_args"></a> [extra\_args](#input\_extra\_args) | list of extra args parameters | `set(string)` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | otel labels | `map(string)` | n/a | yes |
| <a name="input_mode"></a> [mode](#input\_mode) | mode de déploiement | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace Kubernetes ou déployer opentelemetry | `string` | n/a | yes |
| <a name="input_processors_dir"></a> [processors\_dir](#input\_processors\_dir) | Dossier ou trouver les fichiers processors | `string` | n/a | yes |
| <a name="input_receivers_dir"></a> [receivers\_dir](#input\_receivers\_dir) | Dossier ou trouver les fichiers receivers | `string` | n/a | yes |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | replicas | `number` | n/a | yes |
| <a name="input_serviceAccountName"></a> [serviceAccountName](#input\_serviceAccountName) | service account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_otel_collector_manifest"></a> [otel\_collector\_manifest](#output\_otel\_collector\_manifest) | Manifeste CRD OpenTelemetryCollector complet |
| <a name="output_otel_config_yaml"></a> [otel\_config\_yaml](#output\_otel\_config\_yaml) | Config complète générée pour l'OpenTelemetry Collector |