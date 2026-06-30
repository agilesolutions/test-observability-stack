logging {
  level = "info"
}
otelcol.receiver.otlp "default" {
  http {
    endpoint = "0.0.0.0:4318"
  }
  grpc {
    endpoint = "0.0.0.0:4317"
  }
  output {
    metrics = [
      otelcol.processor.batch.default.input,
    ]
    logs = [
      otelcol.processor.batch.default.input,
    ]
    traces = [
      otelcol.processor.batch.default.input,
    ]
  }
}
otelcol.processor.batch "default" {
  output {
    metrics = [
      prometheus.remote_write.default.input,
    ]
    logs = [
      loki.write.default.input,
    ]
    traces = [
      otelcol.exporter.otlp.tempo.input,
    ]
  }
}
prometheus.remote_write "default" {
  endpoint {
    url = "${prometheus_remote_write_url}"
  }
}
// Export logs to your on-premise Loki instance
loki.write "default" {
  endpoint {
    url = "${loki_url}"
  }
}
// Forward the OTLP traces to on-premise Tempo
otelcol.exporter.otlp "tempo" {
  client {
    endpoint = "${tempo_endpoint}"
    tls {
      insecure = true
    }
  }
}