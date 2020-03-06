job "node_metrics" {
  datacenters = ["dc1"]
  type = "system"

  group "node_metrics" {
    count = 1

    task "node_exporter" {
      driver = "docker"

      config {
        image = "quay.io/prometheus/node-exporter:v0.17.0"
        args = ["--path.rootfs", "/host"]
        network_mode = "host"
        pid_mode = "host"
        volumes = [
            "/:/host:ro,rslave",
        ]
      }

      resources {
        cpu    = 100
        memory = 50
      }
    }
  }
}
