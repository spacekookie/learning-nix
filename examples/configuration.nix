# An example configuration.nix that you can build and run in a VM
#
# To do this, get nixos-generators in a nix-shell and then run:
#
# $ nixos-generate -f vm -c ./configuration.nix

{ pkgs, ... }:
{
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "zfs";
  };

  boot.loader.systemd-boot.enable = true;
  environment.systemPackages = [ pkgs.firefox ];

  time.timeZone = "Europe/Amsterdam";
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
}
