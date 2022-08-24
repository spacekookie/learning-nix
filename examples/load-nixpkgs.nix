import <nixpkgs> ({
  overlays = [
    (self: super: {
      htop = builtins.trace "htop in the overlay" super.htop;
    })
  ];
})
