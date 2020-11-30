---
title: Nix!
subtitle: Na das kann ja nix werden
---

# Overview

---

<!-- Using a 3-indent title here to make it fit the slide width, or
TODO: change the title maybe -->

### Somewhat philosophical definition

> nix is an ecosystem for expressing various technological systems.

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

## Declarative onion

This system works in layers!

1. Your configuration sets a value (`users.spacekookie.homeDir = "/home";`)
2. `users` module provides options, and evaluates settings
3. Impure layer: Run `useradd ...`, conditionally based on whether
   that user already exists, etc.

---

## Reproducible

* Nix configuration changes are idempotent

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

Functions are a first-class type in the Nix language/ ecosystem.

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

Note: in the repl, simple assignments are possible (i.e. `a = 5`).
This is not the case in a normal Nix environment (more on that later!)

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
* Comments: `#` for lines, `/* */` for blocks
* `builtins` contains basic operations (`add`, `abort`, ...)
* `nixpkgs` provides more utilities
  * `lib`: generators, and iterator tools
  * `stdenv`: packaging basics (like `mkDerivation`)
  * `pkgs/build-support`: various build utilities (like `fetchFromGitHub`)

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
  * Null ( `null` )

---

### Assignments all the way down

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

* Pre-define a set of variables for a given scope
* There are no "global varibales", only scope-specific bindings

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

---

## `inherit` statement

* Take a value from one scope and move it to another
* Essentially `{ inherit foo; }` is the same as writing `{ foo = foo }`

```nix
let
  package = pkgs.wine.override {
    wineBuild = "wine64";
    wineRelease = "staging";
  };
in
{ 
  inherit package;
}
```

---

## `import` statement

* Not _technically_ a keyword (defined in `builtins`)
* Loads, parses, and imports the nix expression at the given path

```nix
{
  name = "my-i3-setup";
  config = import ./config.nix;
}
```

```nix
{ mod = "Mod4"; /* ... */ }
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

---

## `rec` statement

* Allow for recursive self-referencing in attribute sets
* Can be used as an alternative to `let ... in`

```
nix-repl> { x = y - 10; y = 1322; }.x
error: undefined variable 'y' at (string):1:7

nix-repl> rec { x = y - 10; y = 1322; }.x
1312
```

Quiz: how would you write this with a `let`?

---

## Quiz answer (rec vs let)

```
nix-repl> let 
            y = 1322; 
          in 
            { x = y - 10; inherit y; }.x
1312
```

---

## Destructuring "operator"

* Whenever an attribut set is accepted as a parameter, you can
  destructure it
* Keys become optional via `?` operator
* Additional keys are ignored via `...` operator

```nix
nix-repl> fa = attr: [ attr.a attr.b ]
nix-repl> fb = { a, b }: [ a b ]
nix-repl> fa { a = "a"; b = "b"; }
[ "a" "b" ]
nix-repl> fb { a = "a"; b = "b"; }
[ "a" "b" ]
```

---

## Destructuring "operator"

`f = { a, b }: [ a b ]`

```nix
nix-repl> f { a = "a"; }
error: function at (...) called without required argument 'b'

nix-repl> f { a = "a"; b = "b"; c = "c"; }
error: function at (...) called with unexpected argument 'c'
```

Quiz: change `f` to make the function invocations work

---

## Quiz answer (destructuring)

```nix
nix-repl> f = { a, b ? null, ... }: [ a b ]
nix-repl> f { a = "a"; }
[ "a" null ]
nix-repl> f { a = "a"; b = "b"; c = "c"; }
[ "a" "b" ]
nix-repl> f { a = "a"; c = "c"; }
[ "a" null ]
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

* Load `<nixpkgs>` from `$NIX_PATH` (making it the entry-point)
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

* `with` statement might seem like magic here
* The same can be achieved with a let

```nix
let
  nixpkgs = import <nixpkgs> {};
in
  {
    example = nixpkgs.pkgs.hello;
  }
```

Quiz: what are the `{}` for after the import?

---

## Quiz answer (nixpkgs import)

* `<nixpkgs>` retrieves a path from the `$NIX_PATH` set
* `import <PATH>` loads and parses whatever is there
* `{}` is an empty attribute set passed as a functional parameter
  * This set can be used to override default `nixpkgs` behaviour

---

## Random tangent

* When running `nix repl '<nixpkgs>'` you are telling nix what to load
* Running `nix repl`, you load _nothing_.  This is great to get a feel
  for the structure of `nixpkgs`
  
```consol
 ❤ (uwu) ~> nix repl
Welcome to Nix version 2.3.7. Type :? for help.

nix-repl> <nixpkgs>
/run/current-system/libkookie/nixpkgs

nix-repl> import <nixpkgs>
«lambda @ /run/current-system/libkookie/nixpkgs/pkgs/top-level/impure.nix:15:1»
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

Derivations contain build instructions for a package

![](introduction/01-derivation.png)

---

## Our first package

* Derivations have fields to change (almost) every aspect of the build
  process
* In this case we use `nativeBuildInputs` and `installPhase`
* Because the slides use a `Makefile`, the build step can be
  automatically inferred

```nix
nativeBuildInputs = with pkgs; [ gnumake pandoc ];
installPhase = ''
  mkdir $out
  cp -rv * $out
'';
```

---

## Our first package

* `$out` is a special environment variable during build step
  * points to the derivation output directory
  * try adding `echo $out` or `ls -la $out` into the `installPhase` block
* `nativeBuildInputs` specifies _build time_ dependencies

---

## Our first package

When we put it all together, this derivation generates a `result`
symlink, which contains the built slide deck!

```nix
with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "nix-course";
  src = ./.;

  nativeBuildInputs = with pkgs; [ gnumake pandoc ];
  installPhase = ''
    mkdir $out
    cp -rv * $out
  '';
}
```

---

## And voilá, your first package

You might say...

> but *kookie*, that's not very reproducible?!


# Reproducible builds

---

## Impure source

* Setting `src` to `./.` means, local files are used
* OK for development, but "local files" can change
* Inputs aren't _really_ pinned
  * nix will re-build your program when it has to
  * but builds can randomly break in a deployment
  * ... that's bad!
  
<br/>
  
What's a better solution?


---

## Option 1: fixed output derivation

* **Warning:** _sort of_ depricated (?) (nixpkgs `#2270`)
* **Warning:** they are pretty bad!

</br>

* Build a derivation as normal
* Compare the build artefact hash against a fixed provided hash

TODO: add smallest example of a FOD that's not `fetchurl`

---

## Option 2: fetch sources from elsewhere

// this section is only notes atm!

* Under the hood does the same thing as FOD
* Think about nix as an abstraction onion
  * You can use the unsafe, weird stuff somewhere
  * Don't let it polute the rest of your build steps
  * Rust's `unsafe` is very similar in this regard!
  
---

## Putting this together

```nix
stdenv.mkDerivation rec {
  name = "nix-workshop";
  src = pkgs.fetchurl {
    url = "https://data.spacekookie.de/slides/nix-workshop";
    sha256 = lib.fakeSha256;
  };
  
  # ...
}
```
