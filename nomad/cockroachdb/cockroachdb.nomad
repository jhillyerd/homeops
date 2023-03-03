job "cockroachdb" {
  datacenters = ["skynet"]
  type = "service"

  update {
    max_parallel = 1
    stagger = "30s"
    healthy_deadline = "3m"
  }

  group "db-cluster" {
    count = 3

    constraint {
      distinct_hosts = true
    }

    network {
      port "cluster" { to = 26257 }
      port "sql" { }
      port "http" { }
    }

    service {
      name = "cockroachdb-cluster"
      port = "cluster"

      check {
        name = "CockroachDB Cluster Port Check"
        type = "tcp"
        interval = "10s"
        timeout = "2s"
      }
    }

    service {
      name = "cockroachdb-http"
      port = "http"

      tags = [
        "http",
        "traefik.enable=true",
        "traefik.http.routers.cockroachdb-http.entrypoints=websecure",
        "traefik.http.routers.cockroachdb-http.rule=Host(`cockroach.bytemonkey.org`)",
        "traefik.http.routers.cockroachdb-http.tls.certresolver=letsencrypt",
      ]

      check {
        name = "CockroachDB HTTP Check"
        type = "http"
        path = "/health"
        interval = "10s"
        timeout = "2s"
      }
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 1024 # MB
    }

    task "cockroachdb" {
      driver = "docker"

      config {
        image = "cockroachdb/cockroach:v22.2.5"
        ports = ["cluster", "sql", "http"]

        args = [
          "start",
          "--insecure",
          "--locality=region=${NOMAD_REGION},dc=${NOMAD_DC}",
          "--listen-addr=:26257",
          "--sql-addr=:${NOMAD_PORT_sql}",
          "--http-addr=:${NOMAD_PORT_http}",
          "--advertise-addr=${NOMAD_ADDR_cluster}",
          "--join=${JOINLIST}",
        ]

        volumes = [
          "../alloc/data/cockroach-data:/cockroach/cockroach-data"
        ]
      }

      template {
        change_mode = "noop"
        destination = "cockroachdb.env"
        env = true

        # Generates node list from Consul; may require manually restarting
        # allocs after a cold start.
        data = <<EOH
JOINLIST=localhost{{- range service "cockroachdb-cluster" -}}
,{{ .Address }}:{{ .Port }}
{{- end}}
EOH
      }

      resources {
        cpu = 400 # MHz
        memory = 1024 # MB
      }

      logs {
        max_files = 10
        max_file_size = 5
      }
    }
  }
}
