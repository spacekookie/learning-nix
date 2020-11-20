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


* The same operation yields in the same result
* Build outputs are hashed, and can be re-used

<br />

```
build-01-set = [ 9gkyl3knyalavd5v77rb0ciwry1r4v77-foo
                 gm1vihrf3d8hks2fgjfgfyn5wm2rs49a-bar ]

build-02-set = [ 9gkyl3knyalavd5v77rb0ciwry1r4v77-foo
                 psfi2l3kqpsp2zv66ngnaqhxnbzx1dn7-baz ]
```

Because the hash of `foo` is the same, it can be re-used.

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

* functions `(param: ...)` are first-class types
* functions can be the result of a function: `(b a { param = 5; })`
  passes function `a` to `b` and then calls `b`.
* Parenthesis are your friend: `(b (a { param = 5; }))` calls a with
  `{ param = 5; }`, then the result of that function is passed to `b`.

---

# Nix language


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
