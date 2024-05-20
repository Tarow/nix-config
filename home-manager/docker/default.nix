{
  imports = [
    ./stacks/adguard.nix
    ./stacks/authelia.nix
    ./stacks/books.nix
  ];


  docker = {
    adguard.enable = true;
    authelia.enable = true;
    books.enable = true;
  };
}
