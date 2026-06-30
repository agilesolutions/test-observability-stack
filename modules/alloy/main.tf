resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

##############################################
# Loki- for logs (log aggregation system)
##############################################

# ==========================================
# MINIMAL LOKI HELM RELEASE
# ==========================================
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.6.2"
  namespace  = var.namespace

  values = [
    <<-EOT
    # Run a single, self-contained instance
    deploymentMode: Monolithic

    # ==========================================
    # FIX SCHEMA & NULL POINTER STORAGE ERROR
    # ==========================================
    loki:
      auth_enabled: false
      useTestSchema: true

      # Explicitly declare local filesystem storage to fix the template macro crash
      storage:
        type: filesystem
        bucketNames:
          chunks: chunks
          ruler: ruler
          admin: admin
        filesystem:
          chunks_directory: /var/loki/chunks
          rules_directory: /var/loki/rules

      commonConfig:
        replication_factor: 1
      limits_config:
        retention_period: 24h

    # Zero out SimpleScalable targets so they don't clash with Monolithic
    backend:
      replicas: 0
    read:
      replicas: 0
    write:
      replicas: 0

    # Monolithic single-instance resource constraints
    singleBinary:
      replicas: 1
      persistence:
        enabled: true
        size: 2Gi
      resources:
        limits:
          memory: 300Mi
          cpu: "500m"
        requests:
          memory: 150Mi
          cpu: "100m"

    # Minimal optimizations for Docker Desktop
    gateway:
      enabled: false

    resultsCache:
      enabled: false

    chunksCache:
      enabled: false

    monitoring:
      dashboards:
        enabled: false
      rules:
        enabled: false
      serviceMonitor:
        enabled: false
      selfMonitoring:
        enabled: false
        grafanaAgent:
          enabled: false
    EOT
  ]
}

##############################################
# Tempo- for traces (distributed tracing backend)
##############################################
resource "helm_release" "tempo" {
  name = "tempo"
  namespace = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart = "tempo"
  version = "1.23.2"

  depends_on = [helm_release.loki]

}
##############################################
# Monitoring - for metrics (long-term storage for Prometheus metrics)
##############################################
resource "helm_release" "prometheus" {
  name = "kube-prometheus-stack"
  namespace = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  version = "72.6.3"
  values = [
    templatefile(
      "${path.module}/prometheus-values-minimal-footprint.yaml.tpl",
      {}
    )
  ]

  depends_on = [helm_release.tempo]
}
##############################################
# Grafana Alloy : Grafana’s official open-source OpenTelemetry Collector
##############################################

resource "kubernetes_config_map" "alloy" {
  metadata {
    name      = "alloy-config"
    namespace = var.namespace
  }
  data = {
    "config.alloy" = templatefile(
      "${path.module}/alloy.river.tpl",
      {
        loki_url                    = var.loki_url
        tempo_endpoint              = var.tempo_endpoint
        prometheus_remote_write_url = var.prometheus_remote_write_url
      }
    )
  }

  depends_on = [helm_release.prometheus]

}

resource "helm_release" "alloy" {
  name       = "alloy"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = var.chart_version
  values = [
    templatefile(
      "${path.module}/alloy-values.yaml.tpl",
      {
        namespace = var.namespace
      }
    )
  ]
  depends_on = [
    kubernetes_config_map.alloy
  ]
}