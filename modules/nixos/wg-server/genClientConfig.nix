{
  pkgs,
  lib,
  serverPubKey,
  serverEndpoint,
  dns ? "1.1.1.1",
  ...
}: let
  wg = lib.getExe pkgs.wireguard-tools;
in
  pkgs.writeShellScriptBin "gen_wg_client_conf" ''
      if [ -z "$1" ]; then
        echo "Usage: $0 <client-ip>"
        exit 1
      fi

      CLIENT_IP="$1"

      # Generate keys
      CLIENT_PRIVATE_KEY=$(${wg} genkey)
      CLIENT_PRESHARED_KEY=$(${wg} genpsk)

      cat <<EOF
    [Interface]
    Address = $CLIENT_IP/32
    PrivateKey = $CLIENT_PRIVATE_KEY
    DNS = ${dns}

    [Peer]
    PublicKey = ${serverPubKey}
    PresharedKey = $CLIENT_PRESHARED_KEY
    AllowedIPs = 0.0.0.0/0
    Endpoint = ${serverEndpoint}
    EOF
  ''
