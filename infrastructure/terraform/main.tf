##############################################
# Grafana Alloy : Grafana’s official open-source OpenTelemetry Collector
##############################################

module "alloy" {

  source = "./modules/alloy"

  namespace = var.namespace

  loki_url = var.loki_url

  tempo_endpoint = var.tempo_endpoint

  prometheus_remote_write_url = var.prometheus_remote_write_url

}
