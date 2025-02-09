{ consul, nomad, ... }:
{
  # Telegraf monitoring config.
  http_response = [
    {
      urls = [ "https://consul.bytemonkey.org/ui/" ];
      response_status_code = 200;
    }
    {
      urls = [ "http://demo.inbucket.org/status" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://dockreg.bytemonkey.org/v2/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://forgejo.bytemonkey.org" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://grafana.bytemonkey.org/" ];
      response_status_code = 401;
    }
    {
      urls = [ "https://homeassistant.bytemonkey.org/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://inbucket.bytemonkey.org/" ];
      response_status_code = 200;
    }
    {
      urls = [ "http://msdde3.home.arpa/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://nodered.bytemonkey.org" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://nomad.bytemonkey.org/ui/" ];
      response_status_code = 200;
    }
    {
      urls = [ "https://zwavejs.bytemonkey.org/" ];
      response_status_code = 200;
    }
  ];

  ping = [
    "gateway.home.arpa"
    "msdde3.home.arpa"
    "nexus.home.arpa"
    "nc-um350-1.home.arpa"
    "nc-um350-2.home.arpa"
    "pve1.home.arpa"
    "pve2.home.arpa"
    "pve3.home.arpa"
    "skynas.home.arpa"
    "web.home.arpa"
    "witness.home.arpa"
  ];

  x509_certs =
    [ "https://dash.bytemonkey.org/" ]
    ++ (map (ip: "https://${ip}:8300") consul.servers)
    ++ (map (ip: "https://${ip}:4646") nomad.servers);
}
