{ config, pkgs, ... }:
let
  cowFile = pkgs.runCommand "cowfile-gen" {} ''
    mkdir $out
    echo "Hello" | ${pkgs.cowsay}/bin/cowsay > $out/cow.txt
  '';
in
{
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/fake";

  environment.etc."foo".text = "bar";
  
  users.users.root.password = "1234";
  users.mutableUsers = false;
}
