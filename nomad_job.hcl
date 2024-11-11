job "example" {
  datacenters = ["dc1"]

  group "example-group" {
    task "example-task" {
      driver = "docker"

      config {
        image = "busybox"
        command = "echo"
        args = ["Hello from Nomad"]
      }

      resources {
        cpu    = 500 # MHz
        memory = 128 # MB
        network {
          mbits = 10
        }
      }
    }
  }
}
