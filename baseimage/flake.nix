{
  description = "VM deployment target base images";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators }:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      baseModule = { ... }: {
        services.openssh = {
          enable = true;
          settings.PermitRootLogin = "yes";
        };

        time.timeZone = "US/Pacific";

        users.users.root.openssh.authorizedKeys.keys =
          lib.splitString "\n" (builtins.readFile ../authorized_keys.txt);

        # Display the IP address at the login prompt.
        environment.etc."issue.d/ip.issue".text = ''
          This is a base image.
          IPv4: \4
        '';
        networking.dhcpcd.runHook = "${pkgs.utillinux}/bin/agetty --reload";
      };

      qemuModule = { ... }: {
        boot.kernelParams = [
          "console=ttyS0"
        ];

        services.qemuGuest.enable = true;
      };
    in
    {
      packages.${system} = {
        hyperv = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule ];
          format = "hyperv";
        };

        libvirt = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule qemuModule ];
          format = "qcow";
        };

        proxmox = nixos-generators.nixosGenerate {
          inherit pkgs;
          modules = [ baseModule qemuModule ];
          format = "proxmox";
        };
      };
    };
}
