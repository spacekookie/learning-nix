with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "nix-course";
  src = ./.;

  nativeBuildInputs = with pkgs; [ gnumake pandoc ];

  installPhase = ''
    mkdir $out
    cp -rv * $out
  '';
}
