resource "null_resource" "import_charts" {
  for_each = { for chart in var.charts : chart.chart_name => chart }

  provisioner "local-exec" {
    command = "az acr import --name ${var.acr_server} --source ${var.source_acr_server}/helm/${each.value.chart_name}:${each.value.chart_version} --image ${var.acr_server}/helm/${each.value.chart_name}:${each.value.chart_version}"
  }
}

resource "helm_release" "deployments" {
  for_each = { for chart in var.charts : chart.chart_name => chart }

  depends_on = [null_resource.import_charts]

  name      = each.key
  namespace = each.value.chart_namespace
  repository = var.acr_server
  chart      = each.value.chart_name
  version    = each.value.chart_version   

  dynamic "set" {
    for_each = { for v in each.value.values : v.name => v }
    content {
      name  = set.key
      value = set.value.value
    }
  }

  dynamic "set_sensitive" {
    for_each = lookup({ for i, sv in each.value.sensitive_values : tostring(i) => sv }, "set_sensitive", [])
    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
    }
  }
}
