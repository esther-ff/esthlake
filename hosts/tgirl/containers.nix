{ ... }:

let
  repoName = "/data/git/uuhbot";
  repoBind = "/var/bigeon";
in {
  containers = {
    mezieres = {
      ephemeral = true;
      autoStart = true;

      privateNetwork = true;
      hostAddress = "172.16.0.1";
      localAddress = "172.16.0.5";

      bindMounts = {
        "${repoBind}" = { hostPath = repoName; };
        "/home/bigeon/.minecraft" = { hostPath = "/home/esther/.minecraft"; };
      };

      config = { config, pkgs, lib, ... }: {
        environment.systemPackages = with pkgs; [
          bun
          shadow
          bash
          coreutils
          traceroute
          firefox
        ];

        users.users.bigeon = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          password = "bigeon";
          shell = pkgs.bash;
        };

        # systemd.services.bigeon = {
        #   wantedBy = [ "multi-user.target" ];
        #   after = [ "network.target" ];

        #   description = "bridge bot";

        #   serviceConfig = {
        #     Type = "simple";
        #     User = "bigeon";

        #     WorkingDirectory = "${repoBind}";
        #     ExecStart = "${pkgs.bun}/bin/bun run ${repoBind}/main.ts";
        #     # ExecStart = "";
        #     Restart = "on-failure";
        #     KillMode = "process";
        #   };
        # };

        system.stateVersion = "25.05";

        networking = {
          firewall = {
            enable = false;
            # allowedTCPPorts = [ 443 80 ];
          };

          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
      };
    };
  };
}
