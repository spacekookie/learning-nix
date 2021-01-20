{ ... }:
{
  fileSystems."/".device = "/dev/fake";
  boot.loader.grub.device = "/dev/fake";
  
  users.mutableUsers = false;
  users.users.test = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    password = "test";
  };
}
