with import <nixpkgs> {};
with pythonPackages;

buildPythonPackage rec {
  pname = "doge";
  version = "3.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-spuK/gvPXn3YB/uED4aqfw39lG7pKjQlxsreRQ2gjVM=";
  };
}
