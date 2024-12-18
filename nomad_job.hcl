job "example" {
  datacenters = ["ap-southeast-1-staging"]

  group "example-group" {
    task "example-task" {
      driver = "docker"

      config {
        image   = var.docker_image
        command = "sleep"
        args    = ["3600"]  # Sleep for an hour to keep the task running
      }

      resources {
        cpu    = 250  # MHz
        memory = 128  # MB
        network {
          mbits = 10
        }
      }
    }
  }
}










