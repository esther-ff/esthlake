{
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

    pipewire = {
      enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    openssh.enable = true;
  };

  users.users.esther = {
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
      xwayland = {
        enable = true;
        useSatellite = true;
      };

      niri = {
        enable = true;
        wallpaper = "windows11.jpg";
        wallpaperSource = ../../assets/wallpapers;
      };

      bash = {
        enable = true;
        loginStart = ''
          # if [ "$XDG_VTNR" -eq 1 ] && [ -z "$WAYLAND_DISPLAY" ] && [[ $(tty) = "/dev/tty1" ]]; then
          #     exec niri-session
              # systemctl --user import-environment DISPLAY
              # makes this shit WORK!!
              # dbus-run-session niri-session
          # fi
        '';
      };
    };
  };
}
