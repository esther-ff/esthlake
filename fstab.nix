{ ... }:

{
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
}

