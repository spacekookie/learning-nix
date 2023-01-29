let
  pkgs = import <nixpkgs> { };
  writeCheckedScript = name: text: pkgs.writeTextFile {
    inherit name text;
    executable = true;
    destination = "/bin/mygit";
    checkPhase = ''
      ${pkgs.shellcheck}/bin/shellcheck $out/bin/mygit
    '';
  };
in
writeCheckedScript "work-git" ''
  #!${pkgs.bash}/bin/bash
  ${pkgs.git}/bin/git \
    -c commit.gpgSign=false \
    -c user.email="kookie@spacekookie.de" \
    "$@"
''
