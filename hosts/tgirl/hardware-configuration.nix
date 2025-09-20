{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
        "nvidia_uvm"
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules =
      [ "kvm-amd" "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];

    extraModprobeConfig = ''
      options nvidia_drm fbdev=1 modeset=1
    '';
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a918b7c7-0717-4915-a0b5-ee9948626010";
      fsType = "btrfs";
    };
    "/data" = {
      device = "UUID=9AEC4781EC475723";
      fsType = "ntfs";
      options = [
        "users"
        "nofail"
        "uid=1000"
        "gid=100"
        "auto"
        "umask=077"
        "exec"
        "permissions"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/FA5D-A0F8";
      fsType = "vfat";
    };
  };

  boot = {
    # extraModulePackages = with config.boot.kernelPackages; [ r8168 ];
    # blacklistedKernelModules = [ "r8169" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "tgirl";
    useNetworkd = true;
    firewall.allowedTCPPorts = [ 22 80 443 21 20 ];

    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      externalInterface = "eno1";
    };
  };

}
