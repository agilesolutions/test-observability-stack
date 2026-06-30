alloy:
  configMap:
    create: false
    name: alloy-config
controller:
  type: deployment
service:
  enabled: true
  ports:
    - name: otlp-grpc
      port: 4317
    - name: otlp-http
      port: 4318
    - name: metrics
      port: 12345
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi