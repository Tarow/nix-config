{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    neofetch = prev.neofetch.overrideAttrs (old: {
      src = prev.fetchFromGitHub {
        owner = "dylanaraps";
        repo = "neofetch";
        rev = "87827df455558bd99ca40f443d49a9f7026040f8";
        sha256 = "sha256-merlndX2bST3Zwcoxj8JlISMfMRPDQRzxHAVe1hzgHU=";
      };
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
