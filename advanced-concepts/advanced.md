---
title: Advanced Concepts
---

# Nix CLIs

---

## Nix CLIs

* There's two genders of CLIs in Nix
  * `nix-*` tools vs the new `nix *` tool
* Some things are only implemented in one of the other
* The nix 2 (`nix *`) CLI is unstable!
* Generally the situation is a bit chaotic

---

## Nix CLIs (examples)

---

### Get a nix build out-link

<br/>

**1.0 nix-build**: output build output link

```console
$ nix-build -A hello
these paths will be fetched (0.04 MiB download, 0.20 MiB unpacked):
  /nix/store/8a6lbpbxbc5lc60ljwhw69sszr25ys5f-hello-2.10
copying path '/nix/store/8a6lbpbxbc5lc60ljwhw69sszr25ys5f-hello-2.10' from 'https://cache.nixos.org'...
/nix/store/8a6lbpbxbc5lc60ljwhw69sszr25ys5f-hello-2.10
```

**2.0 nix build**: create `result` symlink to output

```console
$ nix build nixpkgs.hello
$ 
```

---

### Specify `nixpkgs` path

<br/>

**1.0 nix-build**: Specify path via first parameter

```console
$ nix-build '<nixpkgs>' -A hello

$ nix-build . -A hello # if pwd is in a nixpkgs checkout
```

**2.0 nix build**: Optional `-f` parameter

```console
$ nix build -f '<nixpkgs>' hello

$ nix build -f . hello # if pwd is a nixpkgs checkout
```

---

### Many many more differences

* Generally both sets of commands _need_ to be used to achieve all goals
* 1.0 commands are often preferable for scripts and automated tasks
  * Better log output
  * Stable **(!)**
* 2.0 are sometimes more convenient
  * Lack manpages and good documentation

# Overlays & overrides

---

## Overlays

* Additional package changes
* "Overlayed" onto a package set (e.g. `nixpkgs`)
* Allow for local, or organisation-wide overrides
* Implemented as a function

```nix
self: super: {
  htop = self.callPackage ./patches/htop { inherit (super) htop; };
}
```

---

### Overlay structure

* Can be a bit confusing
* Following graph from [nixos.wiki](https://nixos.wiki/wiki/Overlays)
* I find it a bit confusing so following is a breakdown

![](advanced-concepts/overlays1.png)

---

### Overlay structure (1)

* Enjoy some drawings from my eInk tablet
* Situation without any overlays

![](advanced-concepts/overlays2.png)

---

### Overlay structure (2)

* Situation with a single overlay present

![](advanced-concepts/overlays3.png)

---

### Overlay structure (3)

* Same as the nixos.wiki graphic, with two overlays

<img height="550px" src="advanced-concepts/overlays4.png" />

---

## Package overrides

* Don't require an overlay!
  * Can be in-lined in your configuration
  
```nix
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.git.override {
      svnSupport = true;
      sendEmailSupport = true;
    })
  ];
}
```

---

## `override` vs `overrideAttrs`

* `override` overrides attributes in a derivation
* `overrideAttrs` overrides attributes passed to `mkDerivation`

![](advanced-concepts/overrides.png)


---

## Overlay packages

* Putting this together, let's override htop

```console
$ tree patches
patches/
└── htop
    ├── 0001-htop-untruncated-username.patch
    └── default.nix
```

```nix
self: super: {
  htop = self.callPackage ./patches/htop { inherit (super) htop; };
}
```

---

## Overlay packages

* Don't define a new package, override parts of the existing one
* Include as many other dependencies as you need
* Then include patches, or change build steps

```nix
{ htop }:
htop.overrideAttrs ({ patches ? [], ... }: {
  patches = patches ++ [ ./0001-htop-untruncated-username.patch ];
})
```

---

## Including overlays

Two ways, depending on your setup

---

### `nixpkgs-overlays` key in `$NIX_PATH`

* Required to make `nix-shell` use overlay
* Means the overlay needs to stick around at runtime
  * --> breaks if you move it!

---

### Custom `default.nix` root

* Instead of loading `<nixpkgs>` directly, load your `default.nix`
* Then load `nixpkgs` and include the overlay
* Doesn't make `nix-shell` work!

```nix
{ overlays ? [], ... } @ args:

import <nixpkgs> (args // {
  overlays = overlays ++ [ (import ./overlay) ];
})
```

```console
$ nix build -f . htop
... # builds overlay htop
```

---

## Public overlays

* You can include third-party overlays
  * https://github.com/mozilla/nixpkgs-mozilla
  * https://github.com/nix-community/emacs-overlay
  * https://github.com/plapadoo/gdx-nixos-overlay

# Secrets 🤫

---

## Secrets and `/nix/store`

* All files in `/nix/store` are world readable
  * Not a great place to keep secrets & tokens
* Simple work-around: use strings for paths
  * Keep secrets in privileged folder in `/var/lib`
  * Reference via `"/var/lib/foo/secret"`

---

## Manual secrets

* This is not ideal!
* If you move the secrets your deployment/ installation breaks!
* Deploying on a new machine depends on some state!
* Plain-text secrets in backups -> bad?

---

## Overriding activation script

* Store secrets in your build files encrypted
* Rely on activation-time decryption by authorised user

```nix
{ pkgs, ... }:
{
  system.activationScripts.setup-secrets = {
    text = ''
      ${pkgs.gnupg}/bin/gpg --decrypt ${./foo.gpg} > /var/lib/foo/secret
      # ... set the correct owner, etc
    '';
    deps = [];
  };
}
```

---

## Alternative: systemd units

* Activation scripts are complex and **must not** fail!
  * Generates one very long shell script
* If something fails, activation is in an undefined state

Instead: use systemd units! (You already know how!)

```nix
{ pkgs, ... }:
{
  systemd.services.foo-secrets = {
    wantedBy = [ "foo.service" ];
    serviceConfig.user = "foo-user"; # No need to chown manually!
    script = ''
      ${pkgs.gnupg}/bin/gpg --decript ${./foo.gpg} > /var/lib/foo/secret
    '';
  };
}
```

---

## Alternative: `sops-nix`

* SOPS is a secrets management tool by Mozilla
  * Stores secrets in yaml or json config files
  * `sops-nix` makes it work with nix builders

```nix
{ ... }:
let url = "https://github.com/Mic92/sops-nix/archive/master.tar.gz";
in
{
  imports = [ "${builtins.fetchTarball "${url}"}/modules/sops" ];
  sops.defaultSopsFile = ./secrets.yaml;
}
```

Detailed instructions:
[https://github.com/Mic92/sops-nix](https://github.com/johnae/sops-nix)

# Extending system builds

---

## Extending system builds

* You can use `system.extraSystemBuilderCmds` to execute some code
  when building a system configuration
* For example: copy your configuration directory to the nix-store

```nix
{ ... }:
{
  system.extraSystemBuilderCmds = 
  let cfgDir = ../..;
  in
  ''
    ln -s ${lib.cleanSource cfgDir} $out/nix-config
  '';
}
```

# Pinning sources 📌

---

## Pinning sources

* In your projects you may want to pin to specific versions of nixpkgs
  (or other projects)
* No declarative way by default to do this
* `nix-channel` for example is impure: change outside your
  configuration can lead to huge rebuild

What to do about this?

---

## Niv

* Use json configuration to pin to particular nix sources

Consider a `nix/sources.json` file:

```json
{
  "nixpkgs": {
    "url": "https://github.com/NixOS/nixpkgs/archive/109a28ab954a0ad129f7621d468f829981b8b96c.tar.gz",
    "owner": "NixOS",
    "branch": "nixos-19.09",
    "url_template": "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz",
    "repo": "nixpkgs",
    "sha256": "12wnxla7ld4cgpdndaipdh3j4zdalifk287ihxhnmrzrghjahs3q",
    "description": "Nix Packages collection",
    "rev": "109a28ab954a0ad129f7621d468f829981b8b96c"
  }
}
```

---

## Using Niv

* Include sources based on configuration files
* Code auto-generated by `niv init`

```nix
{ sources ? import ./nix/sources.nix }:
with 
{ 
  overlays = [ (_: _: { niv = import sources.niv {}; }) ];
};
import sources.nixpkgs { 
  inherit overlays; config = {};
}
```

---

## Git subtrees

* My favourite method :)
* Include dependencies (nixpkgs, ...) as git subtree
  * Dependency state is pinned via the repository
  * Updates are done via `git fetch` and `git subtree merge ...`
* Lowers (imo) barrier to contribute to nixpkgs

<br />

* Configure `$NIX_PATH` to point to those copies

```console
$ nix build -f '<nixpkgs>' system \
    -I "nixpkgs=$(pwd)/nixpkgs"" \
    -I "nixos-config=$(pwd)/my-config.nix"
...
```

---

## Flakes

* The new hot shit in the pipeline
  * Initially **RFC 0046** (withdrawn)
  * Still very experimental
* Three main attributes for a flake
  * Description (`description`)
  * Set of build inputs (`inputs`)
  * Set of build outputs (`outputs`)
* Configures builds to be `pure-eval` (no network or disk access during evaluation)

---

## Flakes

* Example flake to build the `hello(1)` program.
* It fetches a stable version of nixpkgs from Github.

```nix
{
  description = "Build hello world";
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;
  
  outputs = { self, nipkgs }: {
    with import nixpkgs { system = "x64_64-linux"; };
    stdenv.mkDerivation {
      name = "hello";
      src = self;
      buildPhase = "gcc -o hello ./hello.c";
      installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
    };
  };
}
```

---

## Flakes

The RFC was somewhat controvertial.

* There is an initial experimentation in `nix` 2.0 CLI.
* But this design could change quite fundamentally until the next RFC.


# Code formatting

---

## Code formatting

* No unified style guide
* `nixpkgs` uses various styles
* Several fmt-tools available
* Try to be consistant about it?  (having a style guide per-project/
  per-organisation can help)

Following are some common patterns from nixpkgs.

---

## Attrset formatting

* Usually not split across multiple lines.
* Alphabetical or "priority" ordering
* Put commas first to line up entries

```nix
{ lib, stdenv, pkgs, ... }:
```

```nix
{ mkDerivation, lib, stdenv, makeWrapper, fetchurl, cmake, extra-cmake-modules
, karchive, kconfig, kwidgetsaddons, kcompletion, kcoreaddons
, kguiaddons, ki18n, kitemmodels, kitemviews, kwindowsystem
, kio, kcrash
, boost, libraw, fftw, eigen, exiv2, libheif, lcms2, gsl, openexr, giflib
, openjpeg, opencolorio, vc, poppler, curl, ilmbase
, qtmultimedia, qtx11extras, quazip
, python3Packages
}:
```

---

## List formatting

* Some lists are broken per-item, some are not

```nix
buildInputs = [
  kcompletion kconfigwidgets kcrash kdbusaddons kdesignerplugin ki18n
  kiconthemes kio kwindowsystem qttools
];
```

```nix
buildInputs = [
  breeze-icons
  breeze-qt5
  kconfig
  kcrash
  kdbusaddons
  kfilemetadata
  kguiaddons
  ki18n
  kiconthemes
  kinit
  knotifications
  knewstuff
  karchive
  knotifyconfig
  kplotting
  ktextwidgets
  mlt
  phonon-backend-gstreamer
  qtdeclarative
  qtmultimedia
  qtquickcontrols2
  qtscript
  shared-mime-info
  libv4l
  ffmpeg-full
  frei0r
  rttr
  kpurpose
  kdeclarative
  wrapGAppsHook
];
```

---

## Module patterns

* When creating a module, alias the local option scope in a let

```nix
{ config, lib, ... }:

let cfg = config.foo.bar.my-module;
in
with lib;
{
  options.foo.bar.my-module = {
    # ...
  };
  
  config = mkIf cfg.enable {
    # ...
  };
}
```

---

## Module patterns

* If your configuration block is too complex, move it to a different file

```nix
{ config, lib, ... } @ args:

with lib;
{
  options.foo.bar.my-module = {
    # ...
  };
  
  config = (import ./config.nix args);
}
```

---

## Code formatters

* Personally I don't use them
* None of them are official

* [https://github.com/nix-community/nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)
  * Written in Rust
  * Aims to bring consistency to nixpkgs
* [https://github.com/serokell/nixfmt](https://github.com/serokell/nixfmt)
  * Written in Haskell
  * Adjust the formatting to input style

# Questions?
