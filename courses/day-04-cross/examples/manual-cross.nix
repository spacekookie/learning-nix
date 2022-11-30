with import <nixpkgs> {
  crossSystem.system = "aarch64-linux";
};

stdenv.mkDerivation rec {
  pname = "9menu";
  version = "unstable-2021-02-24";

  src = fetchFromGitHub {
    owner = "arnoldrobbins";
    repo = pname;
    rev = "00cbf99c48dc580ca28f81ed66c89a98b7a182c8";
    sha256 = "arca8Gbr4ytiCk43cifmNj7SUrDgn1XB26zAhZrVDs0=";
  };

  nativeBuildInputs = with pkgsBuildHost; [
    pkg-config meson ninja
  ];

  buildInputs = with pkgsHostTarget; [
    pkg-config meson ninja xorg.libX11 xorg.libXext
  ];
}
