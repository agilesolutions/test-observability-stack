# Open source complete Grafana observability stack to supporting SpringBoot 4 apps
- **The Collector Layer:** [Grafana](https://grafana.com/docs/alloy/latest/) Alloy acts as Grafana’s official, open-source OpenTelemetry Collector distribution. It hosts the otelcol.receiver.otlp block, which actively listens for gRPC (default port 4317) or HTTP/Protobuf (default port 4318) streams coming out of Spring Boot.
- **The Storage Layer:** Once Alloy acts as the single reception front-door, its internal pipeline splits the unified OTLP telemetry data and routes each signal to its respective specialized backend database in the LGTM stack:
    - Loki (for logs)
    - Grafana (for visualization)
    - Tempo (for traces)
    - Mimir or Prometheus (for metrics)
```
[ Spring Boot 4 App ] 
         │ (Unified OTLP stream over ports 4317/4318)
         ▼
 ┌────────────────────────────────────────────────────────┐
 │ Grafana Alloy (`otelcol.receiver.otlp` component)     │ <── Absorbs all data
 └───────────────────┬──────────────┬──────────────┬──────┘
                     │ (Metrics)    │ (Traces)     │ (Logs)
                     ▼              ▼              ▼
                 [ Mimir ]      [ Tempo ]      [ Loki ]


modules/
│
├── Grafana Alloy (OTLP Ingestion Front-Door)
│
├── kube-prometheus-stack
│
├── loki
│
├── tempo
│
└── opentelemetry
```
## SpringBoot microservices integration
Alloy pipelines are setup to offering one central receiver to consume observability data orginating from Spring Boot 4
microservices running on Kubernetes. No file discovery and log scraping needed, instead Alloy acting as a **observability gateway**.

Architecture looks like this:

```
                    Kubernetes

          +----------------------------+
          | Spring Boot Service A      |
          | Spring Boot Service B      |
          | Spring Boot Service C      |
          +-------------+--------------+
                        |
              OpenTelemetry (OTLP)
                        |
                 +------v------+
                 | Grafana Alloy |
                 +------+-------+
                        |
        +---------------+----------------+
        |               |                |
      Logs           Metrics          Traces
        |               |                |
      Loki            Mimir           Tempo
```
## Principle 1 - Applications should only produce telemetry
Your Spring Boot services should not know anything about Loki, Tempo, or Mimir. They simply export telemetry using the OpenTelemetry Protocol (OTLP).
Every service sends everything to Alloy.
## Principle 2 – Alloy is the central collector
Alloy becomes responsible for:

- receiving telemetry
- enriching it
- filtering it
- routing it
- exporting it

Think of it as the equivalent of an enterprise service bus, but for observability data.
## Principle 3 – Use one OTLP receiver
Everything enters through a single receiver. See alloy river template.
```
otelcol.receiver.otlp "default" {

    grpc {}

    http {}

    output {

        metrics = [...]

        logs    = [...]

        traces  = [...]

    }
}
```
## Principle 4 – Separate the three pipelines
Although everything enters through OTLP, you should treat logs, metrics, and traces as independent pipelines.
```
OTLP Receiver
|
+-----------+------------+
|           |            |
Logs      Metrics      Traces
|           |            |
Process     Process      Process
|           |            |
Loki        Mimir       Tempo```
```
## Principle 5 – Add Kubernetes metadata once
One of Alloy's most valuable jobs is enriching telemetry with Kubernetes information such as:

- namespace
- pod
- deployment
- node
- cluster
- container

Instead of each Spring Boot service adding these attributes, Alloy can attach them consistently. Each Spring Boot service should ideally only specify service name, environment and endpoint url to Alloy, that is it.
## A typical production flow
For a Spring Boot 4 microservices platform on Kubernetes, this OTLP-first architecture is considered a clean, vendor-neutral design. It keeps your services focused on business logic while Alloy centralizes observability concerns such as enrichment, filtering, and routing.
```
Spring Boot Service
        │
        │ OTLP
        ▼
 OTLP Receiver
        │
        ▼
Add Kubernetes Metadata
        │
        ▼
Filter / Transform
        │
        ├────────► Loki (logs)
        │
        ├────────► Mimir (metrics)
        │
        └────────► Tempo (traces)
```
## Test Grafana on Docker Desktop
```
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

# For Windows PowerShell Retrieve the Administrator Password
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}")))

username: admin
password: prom-operator

http://localhost:3000

```
Click the Menu icon (Hamburger) in the top-left corner, navigate to Connections, and choose Data sources to verify that Prometheus, Loki, and Tempo display green checkmarks.
## Accessing the Alloy UI Tree
watch the real-time health of your components, targets, and data flow pipelines visually.
```
# In a new terminal window
kubectl port-forward svc/alloy -n monitoring 12345:12345


http://localhost:12345
```







