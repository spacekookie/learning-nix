{
  description = "hello-flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let system = "x86_64-linux";
    in
      {
        defaultPackage."${system}" = with import nixpkgs { inherit system; };
          pkgs.hello;
      };
}
