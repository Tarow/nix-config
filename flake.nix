{
  description = "NixOS and Home Manager Configuration Flake for my Hosts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib.extend (final: prev: (import ./lib final) // home-manager.lib);
    packages = inputs.nixpkgs.legacyPackages;

    mkSystem = {
      system ? "x86_64-linux",
      systemConfig,
      userConfigs ? null,
    }:
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs lib;
        };
        modules =
          [
            {nixpkgs.hostPlatform = system;}
            ./modules/nixos
            systemConfig
          ]
          ++ lib.lists.optionals (userConfigs != null) [
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [./modules/home-manager ./hosts/shared/home.nix];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {inherit inputs outputs lib;};
              home-manager.users = userConfigs;
            }
          ];
      };

    mkHome = {
      system ? "x86_64-linux",
      cfgPath,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = packages.${system};
        extraSpecialArgs = {inherit inputs outputs lib;};
        modules = [
          ./modules/home-manager
          ./hosts/shared/home.nix
          cfgPath
        ];
      };
  in {
    overlays = import ./overlays {
      inherit inputs;
    };

    nixosConfigurations = {
      wsl2 = mkSystem {systemConfig = ./hosts/wsl2/configuration.nix;};
      thinkpad = mkSystem {systemConfig = ./hosts/thinkpad/configuration.nix;};
      desktop = mkSystem {systemConfig = ./hosts/desktop/configuration.nix;};
    };

    homeConfigurations = {
      wsl2 = mkHome {cfgPath = ./hosts/wsl2/home.nix;};
      thinkpad = mkHome {cfgPath = ./hosts/thinkpad/home.nix;};
      desktop = mkHome {cfgPath = ./hosts/desktop/home.nix;};
    };
  };
}
