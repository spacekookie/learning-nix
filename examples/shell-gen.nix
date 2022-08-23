with import <nixpkgs> {};

pkgs.writeTextFile {
  name = "git-update";
  text = import ./script.nix { inherit pkgs; };
  # text = builtins.readFile ./my-script.sh
  destination = "/bin/git-update";
  executable = true;
  checkPhase = ''
    ${shellcheck}/bin/shellcheck $out/bin/git-update
  '';

  
}
