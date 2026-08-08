{
  lib,
  stdenv,
  stdenvNoCC,
  bun,
  nodejs_22,
  fetchFromGitHub,
  makeBinaryWrapper,
  writableTmpDirAsHomeHook,
  python3,
}:
# OpenChamber - web interface for the OpenCode AI agent.
#
# Not packaged in nixpkgs (as of 2026-08). This follows the same build pattern
# as the nixpkgs `opencode` package: a fixed-output derivation that runs
# `bun install --frozen-lockfile` (the only step needing network), then a
# hermetic `vite build` of the web package, mirroring the official Dockerfile.
stdenv.mkDerivation (finalAttrs: {
  pname = "openchamber";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "openchamber";
    repo = "openchamber";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5pVqhwVr44EepRDMIEZeyyvw/Yoi/tFOcPr9RSHus9I=";
  };

  # All dependencies as a fixed-output derivation. The sandbox allows network
  # access here, so bun can fetch the full workspace install.
  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    impureEnvVars =
      lib.fetchers.proxyImpureEnvVars
      ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    # A fixed-output derivation must not contain store path references.
    dontFixup = true;

    outputHash = "sha256-RJoVUH7x0wfSHUWjecNirvdBnjuTZNL1b5gdcrOJyOM=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    nodejs_22
    makeBinaryWrapper
    writableTmpDirAsHomeHook
    python3
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # Compile the node-pty native addon so the in-app terminal works.
    # (Only used when a pty is actually opened; the server degrades gracefully
    # without it. bun-pty is skipped since it would need a cargo build.)
    # Bun's package store is read-only, so make it writable first.
    chmod -R u+w node_modules
    (
      cd node_modules/node-pty
      node ${nodejs_22}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js rebuild \
        --nodedir=${nodejs_22}
    )

    bun run --cwd packages/web build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Keep the upstream packages/web layout: bin/cli.js resolves ../server and
    # ../package.json relative to itself, and the server's dependencies live in
    # packages/web/node_modules (bun does not hoist everything to the root).
    mkdir -p $out/lib/openchamber/packages/web
    cp -r \
      packages/web/bin \
      packages/web/server \
      packages/web/dist \
      packages/web/package.json \
      packages/web/node_modules \
      $out/lib/openchamber/packages/web/
    # Preserve symlinks: bun's node_modules links into the read-only .bun
    # package store via relative symlinks (e.g. @clack/prompts -> ../.bun/...),
    # and sibling dependencies of store entries resolve through them.
    cp -r node_modules $out/lib/openchamber/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs_22} $out/bin/openchamber \
      --add-flags "$out/lib/openchamber/packages/web/bin/cli.js" \
      --prefix PATH : ${lib.makeBinPath [nodejs_22]}

    runHook postInstall
  '';

  meta = {
    description = "Desktop and web interface for the OpenCode AI agent";
    homepage = "https://github.com/openchamber/openchamber";
    changelog = "https://github.com/openchamber/openchamber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "openchamber";
  };
})
