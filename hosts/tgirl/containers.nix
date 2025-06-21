let
  repoName = "/data/git/uuhbot";
  repoBind = "/var/bigeon";
in {
  containers = {
    bigeon = {
      ephemeral = true;
      autoStart = false;

      privateNetwork = true;
      hostAddress = "10.200.200.1";
      localAddress = "10.200.200.2";

      bindMounts = { "${repoBind}" = { hostPath = repoName; }; };

      config = { config, pkgs, lib, ... }: {
        environment.systemPackages = with pkgs; [ bun shadow bash coreutils ];

        users.users.bigeon = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" ];
          password = "bigeon";
          shell = pkgs.bash;
        };

        systemd.services.bigeonBot = {
          wantedBy = [ "multi-user.target" ];
          after = [ "network.target" ];

          description = "Bridge Bot";

          serviceConfig = {
            Type = "simple";
            User = "bigeon";

            WorkingDirectory = "${repoBind}";
            ExecStart = "${pkgs.bun}/bin/bun run ${repoBind}/main.ts";
            # ExecStart = "";
            Restart = "on-failure";

            KillMode = "process";
          };
        };

        system.stateVersion = "24.11";

        networking = {
          firewall = {
            enable = true;
            allowedTCPPorts = [ 443 80 ];
          };

          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;
      };
    };
  };
}
