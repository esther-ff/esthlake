{
  pkgs,
  ...
}:
{
  security = {
    polkit.enable = true;
    pam.services.swaylock.enable = true;
  };

  virtualisation.libvirtd.enable = true;
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
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "ipv4";
      };
    };
  };

  programs.obs-studio.enable = true;
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "pl";
        options = "eurosign:e,caps:escape";
      };

      displayManager = {
        lightdm.enable = false;
        startx.enable = false;
      };
    };

    getty.greetingLine = ''
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣤⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠋⠀⠀⠙⢿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⣸⡇⠀⠀⠀⠀⠀⠙⢿⣦⡀⠀⠀⢀⣀⣀⣠⣤⣀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⣿⠇⠀⠀⠀⠀⠀⠀⠀⠙⠿⠿⠟⠛⠛⠋⠉⠉⠛⣷⡄
      ⠀⠀⠀⠀⠀⠀⠀⢠⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇
      ⠀⠀⠀⠀⣀⣤⣶⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠃
      ⠀⣠⣶⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡿⠃⠀
      ⢸⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠁⠀⠀
      ⢸⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⡀⠀⠀
      ⠀⠙⠿⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⡄⠀
      ⠀⠀⠀⠀⠉⠛⠿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⡄
      ⠀⠀⠀⠀⠀⠀⠀⠘⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇
      ⠀⠀⠀⠀⠀⠀⠀⠀⣿⡆⠀⠀⠀⠀⠀⠀⠀⣠⣶⣶⣦⣤⣤⣄⣀⣀⣤⡿⠃
      ⠀⠀⠀⠀⠀⠀⠀⠀⢹⡇⠀⠀⠀⠀⠀⣠⣾⠏⠀⠀⠀⠈⠉⠉⠙⠛⠉⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣄⠀⠀⣠⣾⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠛⠛⠛⠁⠀
    '';
    openssh.enable = true;
  };

  users.users.esther = {
    hashedPasswordFile = "/run/secrets/user_password";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kvm"
      "libvirtd"
    ];
    shell = pkgs.bash;
  };

  estera = {
    village = {
      home.esther = {
        enable = true;
        name = "esther";
        homeDirectory = "/home/esther";
      };
    };

    secrets.enable = true;
    sound.enable = true;
    vpn.enable = true;

    programs = {
      foot.enable = true;
      fish.enable = true;
      steam.enable = true;
      helix.enable = true;
      wireshark.enable = true;
      zoxide.enable = true;
      fuzzel.enable = true;

      vaultwarden = {
        enable = true;
        environmentFile = "/run/secrets/admin_token_env";
      };

      niri = {
        enable = true;
        autostart = true;
        wallpaper = ../../assets/pastelWaves.jpg;
        screenshotPath = "/data/screenshoty";
      };
    };
  };
}
