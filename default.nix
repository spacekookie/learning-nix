with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "nix-course";
  src = ./.;

  buildInputs = with pkgs; [ gnumake pandoc ];

  installPhase = ''
    mkdir $out
    cp -rv * $out
  '';
}
