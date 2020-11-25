---
title: Nix!
subtitle: Na das kann ja nix werden
---

# Overview

---

<!-- Using a 3-indent title here to make it fit the slide width, or
TODO: change the title maybe -->

### Somewhat philosophical definition

> `nix` is an ecosystem for expressing various technological systems.

---

* building software
* packaging software
* system configuration

---

## Implementation details

* declarative
* reproducible
* functional
* pure
* lazy

---

## Declarative vs Imperative

Tell the computer _what_ to do, not _how_ to do it
  
```nix
users.spacekookie.homeDir = "/home";
```

vs.

```console
$ useradd spacekookie -d /home
```

---

## Declarative wrappers

1. Your configuration sets a value (`users.spacekookie.homeDir = "/home";`)
2. `users` module provides options, and evaluates settings
3. Impure layer: Run `useradd ...`, conditionally based on whether
   that user already exists, etc.

---

## Reproducible

* `nix` configuration changes are idempotent

```nix
users.spacekookie {
  createHome = true;
  home = "/home";
  extraGroups = [ "wheel" "dialout" ];
};
```

Create a user called "spacekookie" with custom home directory and
groups.  Applying this configuration again will do nothing, instead of
yielding an error!

---

## Reproducible

* The same build inputs yield the same build outputs
  * Build *inputs* are hashed, and can be re-used if already built
* If build inputs _may_ change, derivations are fixed by their output
  hash (called "fixed output derivations")

---

## Reproducible

```
build-01-set = [ 9gkyl3knyalavd5v77rb0ciwry1r4v77-foo
                 gm1vihrf3d8hks2fgjfgfyn5wm2rs49a-bar ]

build-02-set = [ 9gkyl3knyalavd5v77rb0ciwry1r4v77-foo
                 psfi2l3kqpsp2zv66ngnaqhxnbzx1dn7-bar ]
```

Because the hash of the `foo` inputs is the same, it can be re-used
from the store.  The `bar` package was updated, and thus needs to be
rebuilt.

---

### Tangent: the nix store

* Usually located at `/nix/store`
* Special permission setup
  * Owned by `root`:`nixbld`
  * Write permissions on `/nix/store` for owner and group
  * No write permissions for actual outputs (e.g. `nix/store/<hash>-foo/`)
  * Setting `t` on `/nix/store` means that removing a file requires
    write-permission on the file, not just the containing directory!

---

### Tangent: the nix store

```
$ /n/s/zzg015adjliwmdm4jfkbhnkpw6dmq1ym-urxvt-autocomplete-all-the-things-1.6.0> tree -p                                                                                   
.
└── [dr-xr-xr-x]  lib
    └── [dr-xr-xr-x]  urxvt
        └── [dr-xr-xr-x]  perl
            └── [-r-xr-xr-x]  autocomplete-ALL-the-things

3 directories, 1 file
```

The result of all this?

A `nixbld` user can create a new directory and store build outputs,
but never remove or change them again!  Build outputs are read-only.

---

## Pure

* Functions have no side-effects
* Inputs map directly to outputs

```nix
{
  makeYouUnderstand = (myCoolFunction {
    giveYouUp = "never";  letYouDown = "never";
    runAround = "never";  desertYou = "never";
    makeyouCry = "never"; sayGoodbye = "never";
  });
}
```

This function is guaranteed to only produce a single output, which
gets assigned to `makeYouUnderstand`.

---

## Functional

Functions are a first-class type in the `Nix` language/ ecosystem.

* Can be passed into functions as parameters
* Can be returned from functions as results
* Syntax is a bit weird:
  * `(argOne: argTwo: argThree: ...)` is a function with three parameters
  * If you have haskell experience this might seem familiar (I do not :P)

---

## Functional examples

A great way to learn the syntax in the `nix repl`! (Run `nix repl
'<nixpkgs>'` to get started)

<br/>

Note: in the `repl`, simple assignments are possible (i.e. `a = 5`).
This is not the case in a normal `Nix` environment!

---

## Functional examples

Having some fun in the nix-repl!

```nix
nix-repl> a = attrs: attrs.param
nix-repl> b = f: val: (x: x + 1) (f val)
nix-repl> a { param = 5; }
5
nix-repl> b a { param = 5; }
6
```

Use parethesis when parameter order is ambigous!

---

## Lazy

Expressions are only evaluated when they are needed for the result of an operation!

```nix
nix-repl> { never = abort "oh no"; use = "I'm a string"; }.use
"I'm a string"
```


# Nix language

---

## Overview

* Implemented in C++ and nix
* `builtins` contains basic tools (such as `add`, `abort`, `import`, ...)
* `nixpkgs` provides more utilities
  * `lib` has more advanced builders, generators, and iterator tools
  * `stdenv` has packaging basics (such as `mkDerivation`)
  * `pkgs/build-support` exports many build utilities (such as `fetchFromGitHub`)

---

## Types

Types are defined in `lib.types` in `nixpkgs`.

* Attribute set (`{ a = 13; b = 12; }`)
* Lists (`[ 1 3 1 2 ]`)
* Functions (`foo: ...`)
* Primitives
  * Two strings: inline vs blocks
    * `"Hello"` vs `''Hello''`
    * Support interpolation with `${}` ("dollar-curly")

---
   
## Types

* Less common types
  * Numbers ( `5` or `1.25` )
  * Boolean ( `true` or `false` )
  * Path ( `/nix/store` or `./.` )
  * URI ( `http://example.com` )
  * Null ( `null` )

---

## Assignments all the way down

```nix
{
  package = pkgs.wine.override {
    wineBuild = "wine64";
    wineRelease = "staging";
  };
}
``` 

* `package = ` defines a key with something
* `pkgs.wine.override { ... }` is a function
* `wineBuild` and `wineRelease` are two keys in an attribute set passed to `wine.override`.


--- 


## `let` statement

```nix
let
  wine = pkgs.wine.override {
    wineBuild = "wine64";
    wineRelease = "staging";
  };
in
{ 
  package = wine; 
}
```

This is the same as the previous example.

---

## `inherit` statement

* The same code can be optimised further with `inherit`
* Take a value from one scope and move it to another

```nix
let
  package = pkgs.wine.override {
    wineBuild = "wine64";
    wineRelease = "staging";
  };
in
  { inherit package; }
```

---

## `import` statement

* Actually defined in `builtins`
* Loads, parses, and imports the nix expression at the given path

```nix
{
  name = "my-i3-setup";
  config = import ./config.nix;
}
```

```nix
{
  mod = "Mod4";
  # ...
}
```

---

## `with` statement

* Load a scope into the following nix expression
* Make all keys from that scope available

```
with lib;
{
  src = with pkgs; fetchFromGitHub {
    owner = "spacekookie";
    repo = "ddos";
    sha256 = fakeSha256;
  };
}
```

## `rec` statement

* Allow for recursive self-referencing in attribute sets
* Can be used as an alternative to `let ... in`

```
nix-repl> { x = y - 10; y = 1322; }.x
error: undefined variable 'y' at (string):1:7

nix-repl> rec { x = y - 10; y = 1322; }.x
1312
```

# Building software

---

## Tangent: `$NIX_PATH`

* Environment variable encoding a key-value store
* Structure: `key=/some/path/on/your/system ...` (space separated)
* Usual keys: `nixpkgs`, `nixos-config`, sometimes `nixpkgs-overlays`
* Accessed in nix via `<>` accessor (e.g. `<nixpkgs>`)
  * `import <nixpkgs>` imports `nixpkgs` key from the path (which is a function)



---

## Standalone builders

* Allow a file to be evaluated as a root
* Load various things into scope (`builtins`, root namespace, ...)

```nix
with import <nixpkgs> {};

{
  # ...
}
```

```console
 ❤ (uwu) ~> nix-build ./test.nix
 ❤ (uwu) ~>
```

---

## Standalone builders

Let's look at the `default.nix` building these slides!

```nix
with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "nix-workshop";
  src = ./.;
  # ...
}
```

`mkDerivation` yields...a derivation! (wow)

What is a derivation?

---

## Tangent: derivations

* `derivation` is a nix built-in function describing a build-action
* Implemented as an attribute set with various mandatory fields
  * Most of the fields have defaults (but can be overriden)

```nix
nix-repl> stdenv.mkDerivation { name = "foo"; }
«derivation /nix/store/2imxf5r8flrps8yw3zds5jffzp37n3a5-foo.drv»

nix-repl> :t stdenv.mkDerivation { name = "foo"; }
a set
```

---

## Tangent: derivations

```
 ❤ (uwu) ~> cat /nix/store/2imxf5r8flrps8yw3zds5jffzp37n3a5-foo.drv

Derive([("out","/nix/store/xxvfx1n970cijvajqgbgwnpcw7iyxipl-foo","","")],
[("/nix/store/3f9cg7nra2vh0wpa0x7gd0cc51aywxmm-stdenv-linux.drv",["out"]),
("/nix/store/5f008h6hhrdf64752j3wxwhmm3xspzcq-bash-4.4-p23.drv",["out"])],
["/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh"],
"x86_64-linux",
"/nix/store/k8p54jg8ipvnfz435mayf5bnqhw4qqap-bash-4.4-p23/bin/bash",
["-e","/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh"],
[("buildInputs",""),("builder","/nix/store/k8p54jg8ipvnfz435mayf5bnqhw4qqap-bash-4.4-p23/bin/bash"),
("configureFlags",""),("depsBuildBuild",""),("depsBuildBuildPropagated",""),
("depsBuildTarget",""),("depsBuildTargetPropagated",""),("depsHostHost",""),
("depsHostHostPropagated",""),("depsTargetTarget",""),("depsTargetTargetPropagated",""),
("doCheck",""),("doInstallCheck",""),("name","foo"),("nativeBuildInputs",""),
("out","/nix/store/xxvfx1n970cijvajqgbgwnpcw7iyxipl-foo"),("outputs","out"),("patches",""),
("propagatedBuildInputs",""),("propagatedNativeBuildInputs",""),
("stdenv","/nix/store/q1zjp9grl4w92qalkdqjs2bj5d0pf8ih-stdenv-linux"),
("strictDeps",""),("system","x86_64-linux")])
```

---



  buildInputs = with pkgs; [ gnumake pandoc ];

  installPhase = ''
    mkdir $out
    cp -rv * $out
  '';
