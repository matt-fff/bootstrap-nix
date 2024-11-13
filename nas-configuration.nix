{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/mnt/doomnas/Library" =
    { device = "//nas1/Library";
      fsType = "cifs";
      options = [ "cache=loose" "credentials=/home/matt/.smbcredentials" "vers=3.0" "uid=1000" "gid=1000" "file_mode=0777" "dir_mode=0777"];
    };

  fileSystems."/mnt/doomnas/Resources" =
    { device = "//nas1/Resources";
      fsType = "cifs";
      options = [ "cache=loose" "credentials=/home/matt/.smbcredentials" "vers=3.0" "uid=1000" "gid=1000" "file_mode=0777" "dir_mode=0777"];
    };

  fileSystems."/mnt/doomnas/Projects" =
    { device = "//nas2/Projects";
      fsType = "cifs";
      options = [ "cache=loose" "credentials=/home/matt/.smbcredentials" "vers=3.0" "uid=1000" "gid=1000" ];
    };
}
