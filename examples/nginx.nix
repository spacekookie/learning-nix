{ ... }:

{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    virtualHosts."main" = {
      default = true;
      locations."/" = {
        root = ./website;
      };
    };
  };
}
