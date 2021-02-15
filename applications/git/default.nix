{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userEmail = "github@alaq.io";
    userName = "Adrien Lacquemant";
  };
}
