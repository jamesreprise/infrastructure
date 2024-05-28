## Installation
1. Install Nix.
```sh
sh <(curl -L https://nixos.org/nix/install)
```
2. Follow the nix-darwin flakes instructions.
To start from scratch, use the following. Otherwise, use the provided 'flake.nix' and skip this step.
```sh
mkdir -p ~/.config/nix-darwin
cd ~/.config/nix-darwin
nix flake init -t nix-darwin
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
```
3. Install nix-darwin.
```sh
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.config/nix-darwin
```

4. Install Xcode developer tools.
```sh
xcode-select --install
```

5. Install Rosetta.
```sh
softwareupdate --install-rosetta
```

6. Correct permissions to homebrew's taps
```sh
chmod +a "${USER} allow list,add_file,search,delete,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,writesecurity,chown" /opt/homebrew/Library/Taps/homebrew/
```
