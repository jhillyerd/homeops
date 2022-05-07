{ config, pkgs, environment, catalog, ... }: {
  imports = [ ../common.nix ];

  # Enable nix flakes, not yet stable.
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "james" ];
  };

  roles.nomad = {
    enableServer = true;

    consulBind = catalog.tailscale.interface;
    consulEncryptPath = config.age.secrets.consul-encrypt.path;
    retryJoin = with catalog.nodes; [ nexus.ip nc-um350-1.ip ];

    nomadEncryptPath = config.age.secrets.nomad-encrypt.path;
  };

  roles.workstation.enable = true;
  roles.workstation.graphical = true;

  networking.firewall.enable = false;

  # Do not enable libvirtd inside of test VM, the inner virtual bridge
  # routing to the outer virtual network, due to using the same IP range.
  virtualisation.libvirtd.enable = environment == "prod";

  age.secrets = {
    consul-encrypt.file = ../secrets/consul-encrypt.age;
    nomad-encrypt.file = ../secrets/nomad-encrypt.age;
  };
}
