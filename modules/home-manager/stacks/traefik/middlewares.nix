name: middlewares: let
  mapping = {
    public = "public-chain@file";
    private = "private-chain@file";
    authelia = "authelia@file";
  };

  validMiddlewares = builtins.filter (key: mapping ? ${key}) middlewares;
in {"traefik.http.routers.${name}.middlewares" = builtins.concatStringsSep "," (map (key: mapping.${key}) validMiddlewares);}
