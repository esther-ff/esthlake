{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  boot = {
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
    ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelModules = lib.mkForce [
      "kvm-amd"
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
      "btrfs"
    ];

    initrd = {
      preDeviceCommands = "";
      kernelModules = lib.mkForce [ "btrfs" ];
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
        "kvm_amd"
      ];
      supportedFilesystems = lib.mkForce [
        "btrfs"
        "vfat"
      ];
      includeDefaultModules = false;
    };

    # extraModulePackages = with config.boot.kernelPackages; [ r8168 ];
    # blacklistedKernelModules = [ "r8169" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    extraModprobeConfig = ''
      options nvidia_drm fbdev=1 modeset=1
    '';
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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

  networking = {
    hostName = "tgirl";
    useNetworkd = true;
    firewall.allowedTCPPorts = [
      22
      80
      443
      21
      20
    ];

    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      externalInterface = "eno1";
    };
  };

}
