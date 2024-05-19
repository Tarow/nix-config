{
  description = "My Arch Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }@inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
    # TODO: Change back to stable release once complex fish abbrs are supported
    pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
    vars = import ./vars.nix;
  in rec{
    overlays = (import ./overlays {inherit inputs;});
   
    homeConfigurations = {
      niklas = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs outputs vars;};
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}

