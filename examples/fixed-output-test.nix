with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "fixed-output";
  src = ./.;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = lib.fakeSha256;
  # outputHash = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  installPhase = ''
    mkdir $out
  '';
}
