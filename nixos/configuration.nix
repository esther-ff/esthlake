# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Mount points
      ./fstab.nix
      # Services
      ./services/services.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Hyprland
  programs.hyprland.enable = true;
  
  nix.settings.experimental-features = ["nix-command" "flakes"];
  
  # Autologin
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = ["" "@${pkgs.util-linux}/sbin/agetty agetty --login-program ${config.services.getty.loginProgram} --autologin esther --noclear --keep-baud %I 115200,38400,9600 $TERM"];
  };

  # Bash starting fish
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        echo "Forwarding to fish!"
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';

    loginShellInit = ''
      echo "Hello!"
      if uwsm check may-start && uwsm select;
      then
        exec uwsm start default
      fi
    '';
  };
  
  
  # Drivers
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   r8168
  # ];
  # boot.blacklistedKernelModules = ["r8169"];
  
  # Fonts
  fonts.packages = import ./fonts.nix pkgs;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = import ./packages.nix pkgs;
  
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "enby"; 
  
  # Enable systemd-networkd
  systemd.network.enable = true;
  
  systemd.network.networks."main" = {
	  matchConfig.Name="eno1";
	  networkConfig.DHCP = "ipv4";
  };

  networking.useNetworkd = true;
  
  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Graphics
  hardware.graphics = {
	  enable = true;
    
  };

  # Pulseaudio
  nixpkgs.config.pulseaudio = true;
  services.pulseaudio.extraConfig = "load-module module-echo-cancel";
  
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "pl";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.esther = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
     shell = pkgs.bash;
   };

  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Polkit
  security.polkit.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  system.stateVersion = "24.11"; 
}

