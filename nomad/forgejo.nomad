job "forgejo" {
  datacenters = ["skynet"]
  type = "service"

  group "forgejo" {
    count = 1

    update {
      # Docs recommend stopping old instances for DB migrations,
      # so no canary and long deadlines.
      canary = 0
      auto_promote = false
      auto_revert = true
      healthy_deadline = "10m"
      progress_deadline = "15m"
    }

    network {
      port "http" { to = 3000 }
      port "ssh" { to = 22 }
    }

    volume "forgejo" {
      type = "host"
      source = "forgejo-data"
      read_only = false
    }

    service {
      name = "forgejo-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.forgejo-http.entrypoints=websecure",
        "traefik.http.routers.forgejo-http.rule=Host(`forgejo.bytemonkey.org`)",
        "traefik.http.routers.forgejo-http.tls.certresolver=letsencrypt",
        # "traefik.http.routers.forgejo-xhttp.entrypoints=extweb",
        # "traefik.http.routers.forgejo-xhttp.rule=Host(`forgejo.x.bytemonkey.org`)",
        # "traefik.http.routers.forgejo-xhttp.tls.certresolver=letsencrypt",
      ]

      check {
        name = "Forgejo HTTP Check"
        type = "http"
        path = "/"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "forgejo-ssh"
      port = "ssh"

      tags = [
        "ssh",
        "traefik.enable=true",
        "traefik.tcp.routers.nomad-ssh.rule=HostSNI(`*`)",
        "traefik.tcp.routers.nomad-ssh.entrypoints=ssh",
      ]

      check {
        name = "Forgejo SSH Check"
        type = "tcp"
        port = "ssh"
        interval = "30s"
        timeout = "2s"
      }
    }

    task "forgejo" {
      driver = "docker"

      config {
        image = "codeberg.org/forgejo/forgejo:10.0.1"
        ports = ["http", "ssh"]
      }

      volume_mount {
        volume = "forgejo"
        destination = "/data"
        read_only = false
      }

      env {
        USER_UID = 1024
        USER_GID = 1000
      }

      resources {
        cpu = 500 # MHz
        memory = 768 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
