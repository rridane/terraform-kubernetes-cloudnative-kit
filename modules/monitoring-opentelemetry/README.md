# 🚀 Module Terraform — OpenTelemetry Collector Generator

Ce module permet de **générer et déployer automatiquement** une ressource
`OpenTelemetryCollector` (CRD de l’OpenTelemetry Operator) à partir de fragments
de configuration organisés dans des dossiers dédiés (`receivers/`, `processors/`, `exporters/`, `connectors/`).

---

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

---

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

---

## ⚙️ Variables

| Variable             | Type        | Description                                       | Exemple                  |
|----------------------|-------------|---------------------------------------------------|--------------------------|
| `namespace`          | `string`    | Namespace Kubernetes où déployer le collector     | `observability`          |
| `receivers_dir`      | `string`    | Chemin vers le dossier receivers                  | `./receivers`            |
| `processors_dir`     | `string`    | Chemin vers le dossier processors                 | `./processors`           |
| `exporters_dir`      | `string`    | Chemin vers le dossier exporters                  | `./exporters`            |
| `connectors_dir`     | `string`    | Chemin vers le dossier connectors                 | `./connectors`           |
| `extra_args`         | `set(string)` | Liste d’arguments supplémentaires                | `["--feature-gates=filelog.allowHeaderMetadataParsing"]` |
| `labels`             | `map(string)` | Labels appliqués à la ressource                  | `{ app = "otel" }`       |
| `replicas`           | `number`   | Nombre de replicas                                | `3`                      |
| `serviceAccountName` | `string`   | Nom du ServiceAccount                             | `otel-collector`         |
| `mode`               | `string`   | Mode du collector (deployment, daemonset, etc.)   | `deployment`             |

---

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

---

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

