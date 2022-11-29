with import <nixpkgs> {};
rustPlatform.buildRustPackage rec {
  pname = "tokei";
  version = "12.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "XAMPPRocky";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jqDsxUAMD/MCCI0hamkGuCYa8rEXNZIR8S+84S8FbgI=";
  };

  cargoSha256 = "sha256-U7Bode8qwDsNf4FVppfEHA9uiOFz74CtKgXG6xyYlT8=";
}
