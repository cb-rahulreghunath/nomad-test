job "nginx" {
  datacenters = ["${datacenter}"]

  group "web" {
    task "nginx" {
      driver = "docker"
      env = ${env_vars}

      config {
        image = "${nginx_image}"
        port_map {
          http = "${nginx_port}"
        }
      }

      resources {
        cpu    = "${cpu}"   # 500 MHz
        memory = "${memory}" # 256MB
      }

      service {
        name = "nginx"
        tags = ["nginx"]
        port = "http"

        check {
          name     = "nginx-http-check"
          path     = "${check_path}"
          interval = "${check_interval}"
          timeout  = "${check_timeout}"
        }
      }
    }
  }
}
