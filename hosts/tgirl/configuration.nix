{ config, pkgs, ... }: {
  # Lonely...!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-emoji
  ];

  time.timeZone = "Europe/Warsaw";
  environment.systemPackages = import ./packages.nix pkgs;
  security.polkit.enable = true;
  system.stateVersion = "24.11";

  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
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

    services."getty@tty1" = {
      overrideStrategy = "asDropin";
      serviceConfig.ExecStart = [
        ""
        "@${pkgs.util-linux}/sbin/agetty agetty -o '-p -- esther' --login-program ${config.services.getty.loginProgram}  --noclear --keep-baud %I 115200,38400,9600 $TERM"
      ];
    };
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  console = { useXkbConfig = true; };

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "pl";
        options = "eurosign:e,caps:escape";
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # pulseaudio.extraConfig = "load-module module-echo-cancel";
    openssh.enable = true;
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    graphics = { enable = true; };
  };

  users.users.esther = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # packages = with pkgs; [ ];
    shell = pkgs.bash;
  };

  estera = {
    home-manager.enable = true;

    programs = {
      alacritty.enable = true;
      fish.enable = true;
      rofi.enable = true;
      steam.enable = true;
      waybar.enable = true;
      xdg-portal.enable = true;
      niri = {
        enable = true;
        wallpaper = "flamingo.png";
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
          echo "woof :3"
          if uwsm check may-start; then
            exec niri-session
          fi
        '';
      };
      wireshark.enable = true;
    };
  };
}

