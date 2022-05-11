# A scratch host for building up new service configurations.
{ pkgs, lib, ... }: {
  imports = [ ../common.nix ];

  services.consul = {
    enable = true;
    webUi = true;

    extraConfig = {
      server = true;
      bootstrap_expect = 1;
      client_addr = "0.0.0.0";
    };
  };

  environment.systemPackages = [ pkgs.vault ];

  services.vault = {
    enable = true;
    storageBackend = "consul";
    # extraConfig = ''
    #   api_addr = "http://{{GetPublicIP}}:8200"
    # '';
  };

  roles.tailscale.enable = lib.mkForce false;

  users.users.root.initialPassword = "root";
  users.users.james.initialPassword = "james";

  networking.firewall.enable = false;
}
