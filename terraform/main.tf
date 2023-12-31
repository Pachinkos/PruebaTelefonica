
module "charts-import" {
  source = "./modules/charts-import"

  acr_server               = "instance.azurecr.io"
  acr_server_subscription  = "c9e7611c-d508-4fbf-aede-0bedfabc1560"
  source_acr_client_id     = "1b2f651e-b99c-4720-9ff1-ede324b8ae30"
  source_acr_client_secret = "Zrrr8~5~F2Xiaaaa7eS.S85SXXAAfTYizZEF1cRp"
  source_acr_server        = "reference.azurecr.io"

  charts = [
    {
      chart_name      = "ping-devops"
      chart_namespace = "default"
      # chart_repository = "chartmuseum"
      chart_version = "0.9.19"

      values = [
        {
          name  = "pingfederate-admin.enabled"
          value = "true"
        },
        {
          name  = "pingfederate-engine.enabled"
          value = "true"
        },
        {
          name  = "pingfederate-engine.container.replicaCount"
          value = "5"
        },
        # {
        #  	name  = "pingfederate-engine.container.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values"
        #  	value = yamlencode(["GroupB"])
        # },
        # {
        # 	name  = "pingfederate-engine.container.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[1].values"
        # 	value = yamlencode(["eu-east", "eu-west"])
        # }
      ]

      sensitive_values = [
        # {
        # 	name = "test"
        # 	value = "true"
        # },
      ]
    }
  ]
}