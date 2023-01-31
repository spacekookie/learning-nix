with import <nixpkgs> {};

rustPlatform.buildRustPackage rec {
  pname = "bat";
  version = "0.22.1";
  
  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-xkGGnWjuZ5ZR4Ll+JwgWyKZFboFZ6HKA8GviR3YBAnM=";
  };

  cargoSha256 = "sha256-ye6GH4pcI9h1CNpobUzfJ+2WlqJ98saCdD77AtSGafg=";
}
