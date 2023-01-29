{ pkgs, ... }:
let
  cowFile = pkgs.runCommand "cowfile-gen" {} ''
    mkdir $out
    echo "Hello" | ${pkgs.cowsay}/bin/cowsay > $out/cow.txt
  '';
in
{
  imports = [ ./gen-config.nix ];
  
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "ext4";
  };

  services.my-config-generator.default = {
    type = "something";
  };

  boot.loader.grub.device = "/dev/fake";

}
