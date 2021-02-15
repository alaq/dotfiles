{ pkgs, ... }: {
  imports = [ 
    ./applications/git ];

    home.packages = with pkgs; [
      nodejs_latest
    ];
}	
