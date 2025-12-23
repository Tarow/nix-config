{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk = {
      ssd = {
        device = "/dev/disk/by-id/todo";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      hdd = {
        type = "disk";
        device = "/dev/disk/by-id/todo";
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/hdd1";
                mountOptions = [
                  "defaults"
                  "nofail"
                ];
              };
            };
          };
        };
      };
    };
  };
}
