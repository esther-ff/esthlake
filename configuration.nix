{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./fstab.nix
    ./services/services.nix
    ./modules/wireguard.nix
  ];

  # Lonely...!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  fonts.packages = import ./fonts.nix pkgs;
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
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';

      loginShellInit = ''
        if uwsm check may-start && uwsm select;
        then
          exec niri
        fi
      '';
    };
  };

  boot = {
    # extraModulePackages = with config.boot.kernelPackages; [
    #   r8168
    # ];
    # blacklistedKernelModules = ["r8169"];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "tgirl";
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 22 ];
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
}

