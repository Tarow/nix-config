{
  disko.devices = {
    disk = {
      ssd = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z2NB1KA22617Z";
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
        device = "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K0VJ5YVS";
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
