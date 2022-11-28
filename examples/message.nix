with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "my-packge";
  dontUnpack = true;
  installPhase = ''
    mkdir $out
    echo "Hello :)" >> $out/message.txt
  '';
}
