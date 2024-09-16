{
  imports = [
    (import ./create-readarr.nix "readarr-ebooks")
    (import ./create-readarr.nix "readarr-audiobooks")
  ];
}
