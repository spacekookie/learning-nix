{ pkgs, ... }:
let
  cowFile = pkgs.runCommand "cowfile-gen" {} ''
    mkdir $out
    echo "Hello" | ${pkgs.cowsay}/bin/cowsay > $out/cow.txt
  '';
in
{
  networking.firewall.allowedTCPPorts = [ 80 ];
  
  services.nginx = {
    enable = true;
    virtualHosts."main" = {
      default = true;
      locations."/" = {
        root = cowFile;
      };
    };
  };

  users.users.root.password = "aoesunth";
  users.mutableUsers = false;
}
