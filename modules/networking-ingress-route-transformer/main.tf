variable "yaml_file" {
  type = string
}

locals {
  applications = yamldecode(file(var.yaml_file))
  routes = merge(values({ for key, routes in flatten([for application in local.applications :
    {for route in application["routes"] : join(".", [route["name"], application["namespace"]]) => {
      namespace : application["namespace"]
      name : route["name"]
      host : route["host"]
      pathPrefix : route["pathPrefix"]
      target-service : route["target-service"]
      port : route["port"]
      stripPrefixMiddlewares : { for key, middleware in route["middlewares"] :
        key => {
          type = middleware["type"]
          prefix = lookup(middleware, "prefix", "")
        } if middleware["type"] == "strip-prefix"
      }
      addPrefixMiddlewares : { for key, middleware in route["middlewares"] :
        key => {
          type   = middleware["type"]
          prefix = lookup(middleware, "prefix", "")
        } if middleware["type"] == "add-prefix"
      }
      overrideHeaderMiddlewares: { for key, middleware in route["middlewares"] :
        key => {
          type   = middleware["type"]
          key = lookup(middleware, "key", "")
          value = lookup(middleware, "value", "")
        } if middleware["type"] == "override-headers"
      }
    }}
  ]) : key => routes })...)
}

output "routes" {
  value = local.routes
}