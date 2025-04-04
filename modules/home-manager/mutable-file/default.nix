# Some files require to be writable. An example are the kubeconfig files, since kubectl tries to write the 'current-context' to its own file.
# These files cannot be managed with the 'home.file' option, since those files will be symlinks to read-only files.
# This module creates writable files by copying the content at activation time. The state is kept in a separate file.
{
  config,
  lib,
  ...
}: let
  cfg = config.tarow.home.mutableFile;

  stateFile = "${config.home.homeDirectory}/.config/tarow/nix-managed-files";
in {
  options.tarow.home.mutableFile = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    description = "Attribute set of writable files where keys are file paths relative to the home directory and values are their content.";
    default = {};
    apply = lib.attrsets.mapAttrs' (key: value: lib.nameValuePair ("$HOME/" + key) value);
  };

  config = {
    home.activation.mutableFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Read the current state file
      state_file="${stateFile}"
      if [[ -f "$state_file" ]]; then
        mapfile -t old_files < "$state_file"
      else
        old_files=()
      fi

      # Delete files from the old state
      for file in "''${old_files[@]}"; do
        [[ -f "$file" ]] && run rm -f "$file"
      done

      # Write new files and update the state file
      run mkdir -p "$(dirname "$state_file")"
      > "$state_file"
      ${lib.concatMapStringsSep "\n" (filePath: ''
        dest="${filePath}"
        run mkdir -p "$(dirname "$dest")"
        run cat <<EOF > "$dest"
        ${cfg.${filePath}}
        EOF
        # chmod u+rw "$dest"
        run echo "$dest" >> "$state_file"
      '') (lib.attrNames cfg)}
    '';
  };
}
