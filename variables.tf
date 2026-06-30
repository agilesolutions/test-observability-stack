variable "namespace" {
  type    = string
  default = "monitoring"
}

variable "chart_version" {
  type    = string
  default = "1.2.1"
}

variable "loki_url" {
  type = string
}

variable "tempo_endpoint" {
  type = string
}

variable "prometheus_remote_write_url" {
  type = string
}