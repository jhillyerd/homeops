let
  james-fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB5SIs0HmrtQN+W7YFqIPpyTqTbRqW8Kq06h2btmXElG";
  james-hypernix =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBIYwEkZGwJbEcZve0qLyTbfuD7eKmtafA8ZWGgYHWUW";
  james-ryzen =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAXHtE9NI16ZPNSKF6Cn0JNJS6fTNQYduerVmVa6WKY";
  users = [ james-fractal james-hypernix james-ryzen ];

  fractal =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdjavkGpkN4niiLWGAjNsaS3R3gxnLn7H4rTtkVkyAt";
  nexus =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmVRmGOyL441FQBbanju9x+VHqLKzwMoDk3dzWtHfKG";
  nixtarget1-hyperv =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILiU0B1BYTeGojG+uo2siv2tpl7PEj3iV0CL8EHyM42e";
  nixtarget1-virtd =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILozTQNcPY2BNQZNW+F29M2euRzD7wZ1XtsKsWFjzpeJ";
  home-systems = [ fractal nexus nixtarget1-hyperv nixtarget1-virtd ];

  nc-um350-1 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMY7Sz0qZCTg2rJNZ1SX61eMosZwPyh0Mq8+kxp5AB31";
  nc-um350-2 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSarN+Keghwq5qltwrvPR0AKNI7nrGoJRkZrl+mTPuO";

  nomad-cluster = [ nexus nc-um350-1 nc-um350-2 fractal ];
in {
  # Common
  "influxdb-telegraf.age".publicKeys = users ++ home-systems ++ nomad-cluster;
  "tailscale.age".publicKeys = users ++ home-systems ++ nomad-cluster;

  # Home
  "cloudflare-dns-api.age".publicKeys = users ++ home-systems;
  "influxdb-admin.age".publicKeys = users ++ home-systems;
  "influxdb-homeassistant.age".publicKeys = users ++ home-systems;
  "mqtt-admin.age".publicKeys = users ++ home-systems;
  "mqtt-sensor.age".publicKeys = users ++ home-systems;
  "nodered.age".publicKeys = users ++ home-systems;

  # Nomad cluster
  "consul-encrypt.age".publicKeys = users ++ nomad-cluster;
  "nomad-encrypt.age".publicKeys = users ++ nomad-cluster;
  "vault-unseal.age".publicKeys = users ++ nomad-cluster;
}
