locals {
  # Séparer directement les groupes par niveau de profondeur
  root_groups = [
    for g in var.groups : g if g.parent == null
  ]

  no_root_groups = [
    for g in var.groups : g if g.parent != null
  ]

  level1_groups = [
    for g in local.no_root_groups : g if length(split("/", g.parent)) == 1
  ]

  level2_groups = [
    for g in local.no_root_groups : g if length(split("/", g.parent)) == 2
  ]

  level3_groups = [
    for g in local.no_root_groups : g if length(split("/", g.parent)) == 3
  ]

  # Combiner dans l'ordre
  sorted_groups = concat(
    local.root_groups,
    local.level1_groups,
    local.level2_groups,
    local.level3_groups
  )
}