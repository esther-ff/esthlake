{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        timeoutStyle = "menu";
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };

    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];

    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/73f8eafc-8ae6-433f-9ee6-f40fc3bf3765";
    fsType = "xfs";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/E1B1-4FD2";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/14e383bc-e364-4cf5-87cd-707df9efad47"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
