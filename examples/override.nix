with import <nixpkgs> {};

self: super: {
  htop = self.callPackage ./htop { htop = super.htop; }
}
