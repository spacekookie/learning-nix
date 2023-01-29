{ lib, config, ... }:
with lib;
let cg = config.services.my-config-generator;
in
{
  options.services.my-config-generator = {
    enable = mkEnableOption "Enable config generator";

    etcName = mkOption { type = types.path; };

    default = {
      type = types.listOf (submodule {
        options = {
          type = lib.mkOption { type = lib.str; };
        };
      });
    };

    config = lib.mkIf cg.enable {
      environment.etc."${cg.etcName}".text = lib.generators.toJSON {
        default = "${cg.default}";
      };
    };
  };
}
