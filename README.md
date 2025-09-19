# Terraform Kubernetes CloudNative Kit

The **CloudNative Kit** is a collection of Terraform modules designed for companies that want to **industrialize and automate Kubernetes** without unnecessary complexity.

The goal: to provide **ready-to-use cloud-native building blocks**.

With this kit, you can:
- deploy networking, security, IAM, and observability components in a standardized way,
- automate processes that are usually heavy and manual,
- reduce the time and cost required to reach a **high level of cloud-native maturity**.

## 🔧 Usage

### Example: deploy Bind9

```hcl
module "bind9" {
  source  = "rridane/cloudnative-kit/kubernetes//modules/bind9"
  version = "0.1.0"

  namespace = "system"
  zones = {
    "example.com" = {
      zone_file = "${path.cwd}/zones/example.com/db.example.com"
      conf_file = "${path.cwd}/zones/example.com/zone.conf.tmpl"
    }
  }
}
```

## 📦 Included sub-modules 

* bind9 - DNS

