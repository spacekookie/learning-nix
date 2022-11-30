with import <nixpkgs> {};

# Call the 'callPackage' function
callPackage

  # Which takes a function as a paramater.  This function must accept
  # any inputs the package needs (but no more, and '...' is forbidden
  # here!).  This function returns a derivation
  ({ stdenv, rustPlatform, fetchFromGitHub }:
    rustPlatform.buildRustPackage rec {
      pname = "tokei";
      version = "12.1.2";
      
      src = fetchFromGitHub {
        owner = "XAMPPRocky";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-jqDsxUAMD/MCCI0hamkGuCYa8rEXNZIR8S+84S8FbgI=";
      };
      
      cargoSha256 = "sha256-U7Bode8qwDsNf4FVppfEHA9uiOFz74CtKgXG6xyYlT8=";
    })

  # Finally callPackage accepts an attribute set with optional
  # overrides.  If none are needed, provide the empty set.
  {
    stdenv
  }
