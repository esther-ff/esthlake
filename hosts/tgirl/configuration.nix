{ config, pkgs, lib, inputs, ... }: {
  # Lonely...!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.modulesTree =
    [ (lib.getOutput "modules" pkgs.linuxPackages_cachyos-lto.kernel) ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.enable = true;
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  documentation = {
    enable = true;
    dev.enable = true;
    man.enable = true;
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.monaspace
  ];

  time.timeZone = "Europe/Warsaw";

  environment = {
    variables = {
      DISPLAY = ":0.0";
      __GL_THREADED_OPTIMIZATIONS = "0";
      EDITOR = "hx";
      VISUAL = "hx";
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
      XDG_SESSION_DESKTOP = "niri";
      MOZ_ENABLE_WAYLAND = "1";
    };

    systemPackages = (import ./packages.nix pkgs)
      ++ [ inputs.ironbar.packages.x86_64-linux.default ];
  };

  security.polkit.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
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

  };

  systemd = {
    network = {
      enable = true;
      networks."main" = {
        matchConfig.Name = "eno1";
        networkConfig.DHCP = "ipv4";
      };
    };

    services."getty@tty1" = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "@${pkgs.util-linux}/sbin/agetty agetty -o '-p -- esther' --login-program ${config.services.getty.loginProgram}  --noclear --keep-baud %I 115200,38400,9600 $TERM"
      ];
    };
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };
  console = { keyMap = "pl"; };

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

    vsftpd = {
      enable = true;
      localUsers = true;
      localRoot = "/home/esther/ftp";
      writeEnable = true;
    };
  };

  users.users.esther = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "kvm" ];
    shell = pkgs.bash;
  };

  estera = {
    home-manager.enable = true;

    programs = {
      alacritty.enable = true;
      fish.enable = true;
      rofi.enable = true;
      steam.enable = true;
      # waybar.enable = true;
      xdg-portal.enable = true;
      niri = {
        enable = true;
        wallpaper = "windows11.jpg";
        wallpaperSource = ../../assets/wallpapers;
      };
      helix.enable = true;
      bash = {
        enable = true;
        interactiveStart = ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';

        loginStart = ''
          if [ "$XDG_VTNR" -eq 1 ] && [ -z "$WAYLAND_DISPLAY" ]; then
              systemctl --user import-environment DISPLAY
              exec niri-session -l
          fi
        '';
      };
      wireshark.enable = true;
      xwayland = {
        enable = true;
        useSatellite = true;
      };
    };
  };
}

