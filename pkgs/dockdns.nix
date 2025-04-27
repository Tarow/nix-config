{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  name = "dockdns";

  src = fetchFromGitHub {
    owner = "Tarow";
    repo = "dockdns";
    rev = "241efd51dae8f85494914567c783cd2622efb81e";
    sha256 = "sha256-Yj8UsfPPPu8XmDT8cU1/7/57TevS8Qthk4bZM9D0WY8=";
  };

  vendorHash = "sha256-QA7RSy4cej53cvR33h9ZC6NpMNQPeErjsTv/Swp8qEA=";
}
