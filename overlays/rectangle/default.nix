{
  pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/b58ada326aa612ea1e2fb9a53d550999e94f1985.tar.gz") {}
}:

pkgs.stdenv.mkDerivation rec {
    name = "rectangle";
    src = pkgs.fetchurl {
        url="https://github.com/rxhanson/Rectangle/releases/download/v0.43/Rectangle0.43.dmg";
        sha256 = "020sf87xxgxzv6a935q3fj67hldk0c1i9iycx9bl9spf44ijjcmc";
    };
    buildInputs = [pkgs.undmg pkgs.unzip];
    sourceRoot = "Rectangle.app";
    phases = ["unpackPhase" "installPhase"];
    installPhase = ''
        mkdir -p "$out/Applications/Rectangle.app"
        cp -pR * "$out/Applications/Rectangle.app"
        '';

    meta = with pkgs.lib; {
        homepage = "https://github.com/rxhanson/Rectangle";
        description = "Move and resize windows on macOS with keyboard shortcuts and snap areas";
        license = licenses.mit;
        maintainers = with maintainers; [ pasqui23 ];
    };
}