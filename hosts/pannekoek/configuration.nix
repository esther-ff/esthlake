{
  pkgs,
  ...
}:
{
  console.enable = false;
  security = {
    polkit.enable = true;
    pam.services.swaylock.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    bigeon = {
      enable = true;
      botToken = "/run/secrets/bigeon_discord_token";
      server = "mc.hypixel.net";
      minecraftUsername = "BallinBridge";
      enableService = true;
      channelName = "guild-chat";
      discordServerId = 1286687362281242736;
    };
  };

  systemd = {
    network = {
      wait-online.enable = false;
      enable = true;
      networks."main" = {
        matchConfig.Name = "enp0s25";
        networkConfig.DHCP = "ipv4";
      };
    };
  };

  services = {
    openssh.enable = true;
  };

  users.users.estera = {
    hashedPasswordFile = "/run/secrets/user_password";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
    ];
    shell = pkgs.bash;
  };

  estera = {
    village = {
      home.estera = {
        enable = true;
        name = "esther";
        homeDirectory = "/home/estera";
      };
    };

    secrets.enable = true;
    sound.enable = true;

    programs = {
      fish.enable = true;
      helix.enable = true;
      wireshark.enable = true;
      zoxide.enable = true;

      vaultwarden = {
        enable = false;
        environmentFile = "/run/secrets/admin_token_env";
      };
    };
  };
}
