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
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  boot = {
    kernelParams = [
      "quiet"
      "loglevel=3"
      "libahci.ignore_sss=1"
    ];
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
    ];
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
    kernelModules = lib.mkForce [
      "kvm-amd"
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
      "btrfs"
    ];

    initrd = {
      kernelModules = lib.mkForce [ "btrfs" ];
      availableKernelModules = [
        # "nvidia"
        # "nvidia_modeset"
        # "nvidia_drm"
        # "nvidia_uvm"
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
      limine.enable = true;
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
      53
      20
      8000
    ];
  };

}
