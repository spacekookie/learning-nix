with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "nix-course";
  src = ./.;

  nativeBuildInputs = [ pandoc ];

  installPhase = ''
    mkdir $out
    cp -rv * $out
  '';
}
