# with import <nixpkgs> {};
# let
#   n = lib.traceVal <nixpkgs>;
# in
# rustPlatform.buildRustPackage {
#   name = "tokei-${n}";
#   src = pkgs.fetchFromGitHub {
#     owner = "XAMPPRocky";
#     repo = "tokei";
#     rev = "v12.1.2";
#     sha256 = "sha256-jqDsxUAMD/MCCI0hamkGuCYa8rEXNZIR8S+84S8FbgI=";
#   };

  
#   cargoSha256 = lib.fakeSha256;
# }


with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "ncdu";
  src = builtins.fetchTarball {
    url = "https://dev.yorhel.nl/download/ncdu-2.1.2.tar.gz";
    sha256 = "1v1dc9z6pjcn88518dkyqd5w6qx2kmbzyjbkcd2s80772jawb6hs";
  };

  # depsBuildHost = [ pkgsBuildHost.zig ];
  buildInputs = [
    pkgsHostTarget.ncurses
  ];

  nativeBuildInputs = [
    pkgsBuildHost.zig
  ];

  # buildPhase = ''
  #   echo $out
  #   ${pkgs.strace}/bin/strace zig build -Drelease-fast
  # '';

  # buildInputs = [ pkgs.ncurses ];

  XDG_CACHE_HOME = "cache";
  PREFIX = builtins.placeholder "out";
}

  /*
    pkgs.fetchTarball { ... }

    https://github.com/thiderman/doge
    https://github.com/XAMPPRocky/tokei
    https://dev.yorhel.nl/ncdu
*/

