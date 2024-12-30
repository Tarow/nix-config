{
  buildGoModule,
  pkgs,
  fetchFromGitHub,
}:
buildGoModule rec {
  name = "discovr";
  nativeBuildInputs = [pkgs.unstable.oapi-codegen];
  src = builtins.fetchGit {
    url = "https://github.com/Tarow/discovr.git";
    ref = "main";
    rev = "3f467898fab5479938e9f6eb82abebae018bbd70";
  };

  vendorHash = "sha256-caTrWbtm9adGe5pEcSHiyMKtMHRizNuqhEe4M72jWcE=";

  preBuild = "make gen";
}
