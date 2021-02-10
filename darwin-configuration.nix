{ config, pkgs, ... }:

let
  extensions = (with pkgs.vscode-extensions; [
    bbenoist.Nix
    esbenp.prettier-vscode
    vscodevim.vim
    ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "vscode-eslint";
        publisher = "dbaeumer";
        version = "2.1.14";
        sha256 = "113w2iis4zi4z3sqc3vd2apyrh52hbh2gvmxjr5yvjpmrsksclbd";
      }
      {
        name = "vspacecode";
        publisher = "vspacecode";
        version = "0.9.0";
        sha256 = "1rhn5avb4icw3930n5bn9qqm7xrpasm87lv2is2k72ks3nxmhsid";
      }
      {
        name = "whichkey";
        publisher = "vspacecode";
        version = "0.8.4";
        sha256 = "0bhx3r08rw9b9gw5pmhyi1g8cb1bb2xmhwg4vpikfkbrs8a30bvi";
      }
      {
        name = "subliminal";
        publisher = "gaearon";
        version = "1.0.0";
        sha256 = "110ms654c26fvqjym10wndfh6hwq8skivvdg4w3zbxvczcsyla52";
      }
      {
        name = "file-browser";
        publisher = "bodil";
        version = "0.2.10";
        sha256 = "1gw46sq49nm85i0mnbrlnl0fg09qi72fqsl46wgd16zf86djyvj5";
      }
      {
        name = "magit";
        publisher = "kahole";
        version = "0.6.4";
        sha256 = "049hc7f3l7lh58smygwhdnv9ag1jym5gvflr1n25db5riqlgimdv";
      }
      {
        name = "fuzzy-search";
        publisher = "jacobdufault";
        version = "0.0.3";
        sha256 = "0hvg4ac4zdxmimfwab1lzqizgq8bjfq6rksc9n7953m9gk6m5pd0";
      }
    ];
  vscode-with-extensions = pkgs.vscode-with-extensions.override {
      vscodeExtensions = extensions;
    };

in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [ pkgs.vim
      vscode-with-extensions
      # pkgs.fira-code
      pkgs.nodejs_latest
    ];

  # macOS settings, restart needed

  # Disable press-and-hold for keys in favor of key repeat
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;
  # Set a blazingly fast keyboard repeat rate
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 10;
  system.defaults.NSGlobalDomain.KeyRepeat = 1;
  # Automatically hide and show the Dock
  system.defaults.dock.autohide = true;
  # Don’t show recent applications in Dock
  system.defaults.dock.show-recents = false;
  # Disable the warning when changing a file extension
  system.defaults.finder.FXEnableExtensionChangeWarning = false;


  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nixpkgs.config.allowUnfree = true;
}
