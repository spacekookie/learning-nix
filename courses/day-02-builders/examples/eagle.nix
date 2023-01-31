with import <nixpkgs> { config.allowUnfree = true; };
let changeVersion = string: builtins.replaceStrings ["9.6.2" "9_6_2"] ["9.5.0" "9_5_0"] string;
in
eagle.overrideAttrs ({ src, version, installPhase, ... }: {
  version = "9.5.0";
  src = let url = changeVersion src.url;
        in pkgs.fetchurl {
          inherit url;
          sha256 = "sha256-HmdkMZInYiqeWqRb2IO2pAgQUyKnoXA7e21WlJRUU3E=";
        };

  installPhase = (changeVersion installPhase);
})
