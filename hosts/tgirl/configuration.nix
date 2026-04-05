{
  pkgs,
  ...
}:
{
  sops =
    let
      keyFilePath = "/home/esther/.config/sops/age/keys.txt";
    in
    {
      age.keyFile = keyFilePath;
      defaultSopsFile = ../../secrets.yaml;
      secrets = {
        mullvad_private_key = { };
        bigeon_discord_token = { };
        admin_token_env = { };
        user_password = { };
      };
    };

  security = {
    polkit.enable = true;
    pam.services.swaylock.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    ssh.extraConfig = ''
      Host codeberg.org
          HostName codeberg.org
          User git
          IdentityFile ~/.ssh/id_ed25519_codeberg
    '';

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

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    openssh.enable = true;
  };

  users.users.esther = {
    hashedPasswordFile = "/run/secrets/user_password";
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    shell = pkgs.bash;
  };

  estera = {
    village = {
      home.esther = {
        enable = true;
        name = "esther";
        homeDirectory = "/home/esther";
        files.meower.content = "hehe";
      };
    };

    village.home.esther.files."barker".content = "hihi";

    programs = {
      foot.enable = true;
      fish.enable = true;
      steam.enable = true;
      xdg-portal.enable = true;
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
        wallpaper = "kibty0.png";
        wallpaperSource = ../../assets/wallpapers;
        screenshotPath = "/data/screenshoty";
      };
    };
  };
}
