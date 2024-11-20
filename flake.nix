{
  description = "NixOS and Home Manager Configuration Flake for my Hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , home-manager
    , arion
    , ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib.extend (final: prev: (import ./lib final) // home-manager.lib);

      mkSystem = { system, cfgPath }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs lib;
          };
          modules = [
            ./modules/nixos
            arion.nixosModules.arion
            cfgPath
          ];
        };

      mkHome = { system ? "x86_64-linux", cfgPath }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = packages.${system};
          extraSpecialArgs = { inherit inputs outputs lib; };
          modules = [
            ./modules/home-manager
            cfgPath
          ];
        };
    in
    {
      overlays = (import ./overlays {
        inherit inputs;
      });

      nixosConfigurations = {
        wsl2 = mkSystem {
          cfgPath = ./hosts/wsl2/configuration.nix;
        };
      };

      homeConfigurations = {
        wsl2 = mkHome {
          cfgPath = ./hosts/wsl2/home.nix;
        };

        thinkpad = mkHome {
          cfgPath = ./hosts/thinkpad/home.nix;
        };
      };
    };
}

