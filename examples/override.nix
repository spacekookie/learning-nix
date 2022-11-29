with import <nixpkgs> {};
{
  my-git = pkgs.git.override {
    svnSupport = true;
    sendEmailSupport = true;
  };
}
