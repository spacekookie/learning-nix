{ lib, config, ... }:

{
  fileSystems."/".device = "/dev/fake";
  boot.loader.grub.device = "/dev/fake";

  users.users.alice = {
    createHome = true;
    isNormalUser = true;
  };
}
