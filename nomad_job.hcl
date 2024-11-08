job "nginx" {
  datacenters = ["dc1"]

  group "nginx-group" {
    count = 1

    task "nginx-task" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500 
        memory = 256 
      }

      service {
        name = "nginx-service"
        port = "http"

        check {
          name     = "nginx-check"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    network {
      port "http" {
        static = 8080
      }
    }
  }
}
