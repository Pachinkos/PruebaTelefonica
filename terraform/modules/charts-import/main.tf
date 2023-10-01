# resource "null_resource" "copy_charts" {
#   for_each = var.charts

#   triggers = {
#     source_acr_server    = var.source_acr_server
#     source_acr_client_id = var.source_acr_client_id
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       az acr helm repo add --name ${var.acr_server} --subscription ${var.acr_server_subscription}
#       az acr helm push --source ${var.source_acr_server}/${each.value.chart_repository}:${each.value.chart_version} --destination ${var.acr_server}/${each.value.chart_repository}
#       EOT
#   }
# }

# data "helm_repository" "instance-repositories" {
#   for_each = { for chart in var.charts : chart.name => chart }

#   name = each.value.chart_name
#   url = each.value.chart_repository
#   chart = each.value.chart_name
#   version = each.value.chart_version
# }


resource "helm_release" "deployments" {
    for_each = { for chart in var.charts: chart.chart_name => chart }
    //for_each = var.charts

    name = each.key
    namespace = each.value.chart_namespace

    //repository = "${helm_repository.instance-repositories[each.value.chart_name].repository}"
    repository = each.value.chart_repository
    chart = each.value.chart_name
    version = each.value.chart_version

    //values = each.value.values
    //sensitive_values = each.value.sensitive_values
    
    # dynamic "set_sensitive" {
    #      for_each = { for sv in each.value.values : sv => sv }
    #      content {
    #          name = set.key
    #          value = set.value
    #      }
    # }

    # set_sensitive = [
    #     for entry in each.value.sensitive_values : {
    #         name  = entry.name
    #         value = entry.value
    #     }
    # ]

    # dynamic "set" {
    # for_each = { for v in each.value.values : v.name => v }
    #     content {
    #         name  = set.key
    #         value = coalesce(v.value, v.listValue)
    #     }
    # }     

    dynamic "set" {
        for_each = { for v in each.value.values : v.name => v }
        content {
            name = set.key
            value = set.value.value
        }
    }

    dynamic "set_sensitive" {
        for_each = lookup({ for i, sv in each.value.sensitive_values : tostring(i) => sv }, "set_sensitive", [])
        content {
        name  = set_sensitive.value.name
        value = set_sensitive.value.value
        #type  = lookup(set_sensitive.value, "type", "auto")
        }
  }

    # values = [
    #     for value in each.value.values : {
    #         name  = value.name
    #         value = value.value
    #     }
    # ]
}
