## Installation
1. Install Nix.
```
sh <(curl -L https://nixos.org/nix/install)
```
2. Follow the nix-darwin flakes instructions.
To start from scratch, use the following. Otherwise, use the provided 'flake.nix'.
```
mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
nix flake init -t nix-darwin
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
```
3. Install nix-darwin.
```
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.config/nix-darwin
```
