with import <nixpkgs> {};
stdenv.mkDerivation rec {
  pname = "ncdu";
  version = "2.2.1";

  src = pkgs.fetchurl {
    url = "https://dev.yorhel.nl/download/ncdu-${version}.tar.gz";
    sha256 = "sha256-Xkr49rzYz3rY/T15ANqxMgdFoEUxAenjdPmnf3Ku0UE=";
  };

  # In order to debug why the Zig build fails (with "Permission
  # Denied"), include strace in the build environment
  # (nativeBuildInputs) and use it to show which files and/or
  # directories the compiler is trying to open.

  # buildPhase = ''
  #   ${pkgs.strace}/bin/strace zig build
  # '';

  nativeBuildInputs = with pkgs; [ zig /* strace */ ];
  buildInputs = [ pkgs.ncurses ];

  # The following environment variables must be set in the build
  # environment to make the build succeed.  XDG_CACHE_HOME (or HOME)
  # changes where Zig tries to store temporary files.  PREFIX must be
  # changed to the output directory (Zig by default wants to install
  # into /usr)

  XDG_CACHE_HOME = "Cache";
  PREFIX = placeholder "out";
}
