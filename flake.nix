{
  description = "My Arch Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      packages = inputs.nixpkgs.legacyPackages;

      mkHome = { system, homePath, vars ? { } }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = packages.${system};
          extraSpecialArgs = { inherit inputs outputs vars; };
          modules = [
            ./modules/home-manager
            homePath
          ];
        };
    in
    {
      overlays = (import ./overlays {
        inherit inputs;
      });

      homeConfigurations = {
        wsl2 = mkHome {
          system = "x86_64-linux";
          homePath = ./hosts/wsl2/home.nix;
          vars = import ./hosts/wsl2/vars.nix;
        };
      };
    };
}

