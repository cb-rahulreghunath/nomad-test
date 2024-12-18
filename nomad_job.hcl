variable "example_variable" {
  type    = string
  default = "default_value"
}

job "example" {
  datacenters = ["ap-southeast-1-staging"]

  group "example-group" {
    task "example-task" {
      driver = "docker"

      config {
        image   = "busybox"
        command = "sleep"
        args    = ["3600"]  # Sleep for an hour to keep the task running
      }

      resources {
        cpu    = 500  # MHz
        memory = 128  # MB
        network {
          mbits = 10
        }
      }
    }
  }
}
