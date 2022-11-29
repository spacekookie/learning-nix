with import <nixpkgs> {};
stdenv.mkDerivation rec {
  pname = "ncdu";
  version = "2.2.1";

  src = pkgs.fetchurl {
    url = "https://dev.yorhel.nl/download/ncdu-${version}.tar.gz";
    sha256 = "sha256-Xkr49rzYz3rY/T15ANqxMgdFoEUxAenjdPmnf3Ku0UE=";
  };

  XDG_CACHE_HOME = "Cache";
  # HOME = "$TMPDIR";

  PREFIX = placeholder "out";
  
  buildPhase = ''
    mkdir -p $out
    zig build
  '';

  
  nativeBuildInputs = [ pkgs.zig ];

  buildInputs = [ pkgs.ncurses ];
}
