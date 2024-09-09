{ lib, ... }:
{
  # This module will import all submodules (the default.nix in each subfolder).
  # Each module should have a enable flag, which is false by default.
  # Enabling certain modules should happen in a profile (see the profiles folder on root level).
  # Additionally, you can also enable certain modules and settings in your user configuration.

  # When you add a new module, make sure to add an enable flag which defaults to false, so your options won't be automatically set.
  imports = (lib.tarow.readSubdirs ./.);
}
