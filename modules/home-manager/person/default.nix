# Module, that only exposes options with general information that will be used by other modules
{ pkgs, lib, config, ... }:
{
  options.tarow.person = {
    name = lib.options.mkOption {
      type = lib.types.str;
      example = ''Max Mustermann'';
      description = "Your full name which will be used for Git config etc";
    };
    email = lib.options.mkOption {
      type = lib.types.str;
      example = ''max.mustermann@vodafone.om'';
      description = "Your e-mail address will be used for Git config etc";
    };
  };
}