job "example-voting-app" {

  datacenters = ["aero-cluster"]
  type = "service"

      group "web" {
        count = 1

        task "nginx" {
          driver = "docker"
          config {
            image = "crizstian/example-voting-nginx:v0.1"
            port_map {
             service_port = 80
            }
            force_pull = true
          }

          env {
              PROXIED_SERVICE_1="vote"
              PROXIED_SERVICE_2="result"
          }

            resources {
              network {
                  mbits = 10
                  port "service_port" {
                    static=80
                  }
                  port "aero" {}
              }
            }
        }
    }

  group "vote" {
    count = 1

    task "vote" {
      driver = "docker"
      config {
        image   = "crizstian/vote:v0.1"
        port_map {
          service_port = 80
        }
      }

      resources {
        network {
            mbits = 10
            port "service_port" {}
            port "aero" {}
        }
      }
      service {
        name = "example-voting-app-vote"
        tags = [ "example-voting-app" ]
        port = "service_port"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "result" {
    count = 1

    task "result" {
      driver = "docker"
      config {
        image   = "crizstian/result:v0.1"
        port_map {
          service_port = 80
          service_port_1 = 5858
        }
      }

      resources {
        network {
            mbits = 10
            port "service_port" {}
            port "service_port_1" {}
            port "aero" {}
        }
      }
      service {
        name = "example-voting-app-result"
        tags = [ "example-voting-app" ]
        port = "service_port"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
  
  group "redis" {
    count = 1

    task "redis" {
      driver = "docker"
      config {
        image = "redis:alpine"
        port_map {
          service_port = 6379
        }
      }

      resources {
        network {
            mbits = 10
            port "service_port" {}
            port "aero" {}
        }
      }
      service {
        name = "example-voting-app-redis"
        tags = [ "redis" ]
        port = "service_port"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "db" {
    count = 1

    task "db" {
      driver = "docker"
      config {
        image = "postgres:9.4"
        port_map {
          service_port = 5432
        }
        volumes = [
          "/db-data:/var/lib/postgresql/data"
        ]
      }

      resources {
        network {
            mbits = 10
            port "aero" {}
            port "service_port" {}
        }
      }
      service {
        name = "example-voting-app-db"
        tags = [ "db" ]
        port = "service_port"
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

    group "worker" {
    count = 1

    task "worker" {
      driver = "docker"
      config {
        image   = "crizstian/worker:v0.1"
      }
    }
  }
}