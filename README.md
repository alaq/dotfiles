# Nix dotfiles

> A Nix configuration for macOS and Linux

## Running on a fresh macOS machine

1. Install Google Chrome
1. Install [nix](https://nixos.org/nix/). For macOS, Catalina and up, use:

    ```shell
    sh <(curl -L https://nixos.org/nix/install) --darwin-use-unencrypted-nix-store-volume
    ```

1. Install [nix-darwin](https://github.com/LnL7/nix-darwin)
    ```shell
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer
    rm -rf result
    ```
1. Clone this repo into `~/.nixpkgs`
1. Build

    ```shell
    darwin-rebuild switch
    ```

1. Reboot for the macOS configuration changes to take effect
1. Copy `keybindings.json` and `settings.json` to `~/Library/Application Support/Code/User/`

## Running on Linux

1. Install [nix](https://nixos.org/nix/)
1. Clone this repo into `~/.nixpkgs`
1. Add to your bashrc:

    ```shell
    nix-shell ~/.nixpkgs/shell.nix
    ```

## Reference

-   https://github.com/bkase/life/blob/master/README.md
