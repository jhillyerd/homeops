# Catalog defines the systems & services on my network.
{ system }: rec {
  nodes = import ./nodes.nix { inherit system; };
  services = import ./services.nix { inherit nodes nomad; };

  authelia = {
    host = nodes.web.ip.priv;
    port = 9091;
  };

  influxdb = rec {
    host = nodes.nexus.ip.priv;
    port = 8086;
    telegraf.user = "telegraf";
    telegraf.database = "telegraf-hosts";
    urls = [ "http://${host}:${toString port}" ];
  };

  consul = {
    servers = with nodes; [
      nexus.ip.priv
      nc-um350-1.ip.priv
      nc-um350-2.ip.priv
    ];
  };

  nomad = {
    servers = with nodes; [
      nexus.ip.priv
      nc-um350-1.ip.priv
      nc-um350-2.ip.priv
    ];

    skynas-host-volumes = [
      "gitea-storage"
      "grafana-storage"
      "homeassistant-data"
      "nodered-data"
      "satisfactory-data"
      "waypoint-runner-data"
      "waypoint-server-data"
      "zwavejs-data"
    ];
  };

  # Named TCP/UDP load balancer entry points.
  traefik.entrypoints = {
    factorygame = ":7777/udp";
    factorybeacon = ":15000/udp";
    factoryquery = ":15777/udp";

    smtp = ":25/tcp";
    ssh = ":222/tcp";
    websecure = ":443/tcp";
    extweb = ":8443/tcp";
  };


  cf-api.user = "james@hillyerd.com";

  dns.host = nodes.nexus.ip.priv;

  syslog.host = nodes.nexus.ip.priv;
  syslog.port = 1514;

  smtp.host = "mail.home.arpa";

  tailscale.interface = "tailscale0";

  # Layout of services on the dashboard.
  layout = [
    {
      section = "Services";
      services = [ "gitea" "grafana" "homeassistant" "inbucket" "nodered" "octopi" ];
    }
    {
      section = "Cluster";
      services = [ "cockroach" "consul" "nomad" "proxmox" "dockreg" ];
    }
    {
      section = "Infrastructure";
      services = [ "modem" "skynas" "traefik" "unifi" "zwavejs" ];
    }
  ];
}
