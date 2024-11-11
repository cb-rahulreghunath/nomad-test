job "simple" {
  datacenters = ["dc1"]

  group "example" {
    task "hello" {
      driver = "docker"
      config {
        image = "alpine"
        command = "echo"
        args = ["Hello, Nomad!"]
      }
    }
  }
}
