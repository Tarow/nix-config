{lib, ...}: {
  imports = lib.tarow.readSubdirs ./.;

  options.tarow.stacks = {
    storageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/niklas/.stacks";
    };
    mediaStorageBaseDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/hdd1/media";
    };
  };
  config = {
  };
}
