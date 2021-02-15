{ pkgs, ... }: {
  imports = [ 
    # ./applications/zsh 
    # ./applications/rectangle
    ./applications/git ];

    home.packages = with pkgs; [
      nodejs_latest
    ];
}	
