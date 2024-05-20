{
  imports = [
    ./stacks/adguard.nix
    ./stacks/authelia.nix
    ./stacks/books.nix
    ./stacks/bookstack.nix
    ./stacks/calibre.nix
    ./stacks/changedetection.nix
    ./stacks/cloudflare-ddns.nix
    ./stacks/code-server.nix
    ./stacks/crowdsec.nix
  ];


  docker = {
    adguard.enable = true;
    authelia.enable = true;
    books.enable = true;
    bookstack.enable = false;
    calibre.enable = false;
    changedetection.enable = false;
    cloudflare-ddns.enable = false;
    code-server.enable = true;
    crowdsec.enable = true;
  };
}
