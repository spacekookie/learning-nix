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

### Specify `<nixpkgs>` path

<br/>

**1.0 nix-build**: Take `$NIX_PATH` key as first parameter

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

---

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

![](./overlays.png)

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


