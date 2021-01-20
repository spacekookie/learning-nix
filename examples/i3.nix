/**
 * Define a simple attribute set that imports an external 
 * attribute set with configuration values to load.
 */
{
  name = "my-i3-config";
  config = import ./config.nix;
}
