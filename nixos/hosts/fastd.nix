{
  config,
  pkgs,
  self,
  util,
  ...
}:
{
  imports = [
    ../common.nix
    ../common/onprem.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];

  # Listed extra pools must be available during boot.
  boot.zfs.extraPools = [ "fast1" ];

  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    dataDir = "/fast1/database/postgresql/${config.services.postgresql.package.psqlSchema}";

    authentication = ''
      host all all all scram-sha-256
    '';

    ensureDatabases = [
      "root"
      "gitea"
      "forgejo"
    ];

    ensureUsers = [
      {
        name = "root";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
        ensureClauses.login = true;
      }
      {
        name = "forgejo";
        ensureDBOwnership = true;
        ensureClauses."inherit" = true;
        ensureClauses.login = true;
      }
      {
        name = "gitea";
        ensureDBOwnership = true;
        ensureClauses."inherit" = true;
        ensureClauses.login = true;
      }
    ];
  };

  services.openiscsi = {
    enable = true;
    enableAutoLoginOut = true;
    name = "iqn.1999-11.org.bytemonkey:fastd";
  };

  # Import iSCSI ZFS pools.
  systemd.services.zfs-import-backup1 =
    let
      zpoolcmd = "/run/current-system/sw/bin/zpool";
      pool = "backup1";

      script.start = ''
        if ! ${zpoolcmd} list ${pool} >/dev/null 2>&1; then
          ${zpoolcmd} import ${pool}
        fi
      '';

      script.stop = ''
        if ${zpoolcmd} list ${pool} >/dev/null 2>&1; then
          ${zpoolcmd} export ${pool}
        fi
      '';
    in
    {
      # Give iSCSI time to login to NAS.
      preStart = "/run/current-system/sw/bin/sleep 5";

      script = script.start;

      wantedBy = [ "multi-user.target" ];
      requires = [ "iscsi.service" ];
      after = [ "iscsi.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStop = "${pkgs.writeShellScript "stop-zfs-backup1" script.stop}";
      };
    };

  services.syncoid = {
    enable = true;
    interval = "minutely";

    localSourceAllow = [
      "bookmark"
      "hold"
      "mount" # added
      "send"
      "snapshot"
      "destroy"
    ];

    localTargetAllow = [
      "change-key"
      "compression"
      "create"
      "destroy" # added
      "mount"
      "mountpoint"
      "receive"
      "rollback"
    ];

    # Volumes to backup.
    commands."fast1/database".target = "backup1/database";

    service.after = [ "zfs-import-backup1.service" ];
  };

  # Collect snapshot stats.
  roles.telegraf.zfs = true;

  systemd.network.networks = util.mkClusterNetworks self;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.settings.port ];
}
