{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
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
  boot.initrd.kernelModules = [ ];
  boot.kernelModules =
    [ "kvm-amd" "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];

  boot.extraModprobeConfig = ''
    options nvidia_drm fbdev=1 modeset=1
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a918b7c7-0717-4915-a0b5-ee9948626010";
    fsType = "btrfs";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics.enable32Bit = true;

  fileSystems."/data" = {
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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FA5D-A0F8";
    fsType = "vfat";
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
    firewall.allowedTCPPorts = [ 22 80 443 ];

    nat = {
      enable = true;
      internalInterfaces = [ "ve-*" ];
      externalInterface = "eno1";
    };
  };

}
