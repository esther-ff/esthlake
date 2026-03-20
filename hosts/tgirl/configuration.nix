{
  config,
  pkgs,
  ...
}:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

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

    vaultwarden = {
      enable = true;
      backupDir = "/var/backup/vw";
      environmentFile = "/run/secrets/admin_token_env";
      config = {
        ROCKET_PORT = 8768;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_LOG = "warn";
        SIGNUPS_ALLOWED = false;
      };
    };

    caddy = {
      enable = true;
      globalConfig = ''
        skip_install_trust
        auto_https disable_redirects
      '';
      virtualHosts."https://localhost:8000, https://192.168.0.2:8000".extraConfig = ''
        reverse_proxy localhost:${toString config.services.vaultwarden.config.ROCKET_PORT} {
          header_up X-Real-IP {remote_host}
        }

        tls internal
      '';
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
      "libvirtd"
      "kvm"
    ];
    shell = pkgs.bash;
  };

  estera = {
    home-manager.enable = true;

    programs = {
      foot.enable = true;
      fish.enable = true;
      rofi.enable = true;
      steam.enable = true;
      xdg-portal.enable = true;
      helix.enable = true;
      wireshark.enable = true;
      zoxide.enable = true;

      xwayland = {
        enable = true;
        useSatellite = true;
      };

      niri = {
        enable = true;
        wallpaper = "kibty0.png";
        wallpaperSource = ../../assets/wallpapers;
        screenshotPath = "/data/screenshoty";
      };

      bash = {
        enable = true;
        loginStart = ''
          if [ "$XDG_VTNR" -eq 1 ] && [ -z "$WAYLAND_DISPLAY" ] && [[ $(tty) = "/dev/tty1" ]]; then
              echo "launching niri"
              niri-session &
          fi
        '';
      };
    };
  };
}
