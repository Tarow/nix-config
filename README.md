# nix-config

[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)
![example workflow](https://github.com/tarow/nix-config/actions/workflows/ci.yaml/badge.svg)
[![Renovate](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com)

## Tooling

- [NixOS](https://nixos.org/) - System Configuration
- [Home Manager](https://github.com/nix-community/home-manager) - Home Configuration
- [sops-nix](https://github.com/Mic92/sops-nix) - Secret Management
- [stylix](https://github.com/danth/stylix) - Color Schemes

## Bootstrap

Drop into nix devshell:

```bash
 nix develop github:Tarow/nix-config
```

Clone repository:

```bash
git clone https://github.com/Tarow/nix-config.git ~/nix-config && cd ~/nix-config
```

Manually restore SSH private key and use it to generate age key used by [sops-nix](https://github.com/Mic92/sops-nix).

```bash
mkdir -p ~/.config/sops/age && ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o ~/.config/sops/age/keys.txt
```

---

#### Install System Configuration:

```bash
nixos-rebuild switch --flake .#<host>
```

#### Install Home Configuration:

```bash
home-manager switch -b bak --flake .#<host>
```
