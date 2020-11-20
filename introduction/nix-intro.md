---
title: Nix!
subtitle: Na das kann ja nix werden
---

# What is nix?

---

<!-- Using a 3-indent title here to make it fit the slide width, or
TODO: change the title maybe -->

### Somewhat philosophical definition

> `nix` is an ecosystem for expressing various technological systems.

---

* build steps
* packaging
* system configuration

---

## Implementation details

* declarative
* reproducible
* functional
* pure

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
  * Build inputs are hashed, and can be re-used if already built
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
built.

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
    giveYouUp = "never";
    letYouDown = "never";
    runAround = "never";
    desertYou = "never";
    makeyouCry = "never";
    sayGoodbye = "never";
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

Note: in the `repl`, simple assignments are possible (i.e. `a = 5`).
This is not the case in a normal `Nix` environment!

---

## Functional examples

Having some fun in the nix-repl!

```nix
nix-repl> a = (attrs: attrs.param)
nix-repl> b = (funct: (val: val + 1) funct)
nix-repl> a { param = 5; }
5
nix-repl> b (a { param = 5; })
6
```

Use parethesis when parameter order is ambigous!

---

# Nix language

---


```nix
{
  package = (pkgs.wine.override {
    wineBuild = "wine64";
    wineRelease = "stagingi";
  });
}
```

* `package = ` defines a key with something
* `pkgs.wine.override { ... }` is a function
* Wrapping it in `(...)` calls the function
* `wineBuild` and `wineRelease` are two keys in an attribute set passed to `wine.override`.

---

## `let` statement

```nix
let
wine = pkgs.wine.override {
  wineBuild = "wine64";
  wineRelease = "stagingi";
}
in
{ 
  package = wine; 
}
```

This is the same as the previous example.
