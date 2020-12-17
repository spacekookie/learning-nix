---
title: Module system
subtitle: A deep(ish) dive into the nix module system
---

# Overview

---

## Overview

* A module in Nix is a function with a specific API
  * `options`: nested set of all options declarations
  * `config`: nested set of all option values
  * `lib` and `pkgs` to access utilities
* The modules are also split into `options` and `config`

---

## Modules are functions

* `{ config, lib, ... }:` is a deconstructed function argument
* Loading happens via `imports` attribute set key

```nix
{ ... }:

{
  imports = [ ./part1.nix ./part2.nix ];
}
```

---

## Using modules

* Creating system configuration is done by setting module options

```nix
{ config, lib, pkgs, ... }:
{ 
  # ...
  systemd.services.helloService = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.hello}/bin/hello -g "Hello, nyantec"
      '';
      Type = "oneshot";
    };
  };
}
```

---

**Find modules**: [https://search.nixos.org/options](https://search.nixos.org/options)

![](module-system/module-railcar.png)


# Writing modules

---

## Short recap

* Everything in nix is an attribute set
  * `{ a = "foobar"; b = { ... }; }`
* Module system uses some "magic keys"
  * `imports`, `options`, `config`
* Modules are parsed into two nested sets

Putting all this together we can write our first module!

---

## Writing modules

```nix
{ config, lib, pkgs, ... }: 

{
  options.hello = {
    enable = lib.mkEnableOption "hello service";
  };
  
  config = lib.mkIf config.hello.enable {
    systemd.services.helloService = { ... };
  };
}
```

---

## Using `hello` module

After we include the module (more on that later) the
`services.hello.enable` key is available to us!

```nix
{ ... }: 
{
  # ...
  
  imports = [ ./hello-module.nix ];
  services.hello.enable = true;
}
```

---

## Module options with types

* Just having a single enable switch is maybe somewhat pointless
* Module system type system provided by `lib.types`

```nix
{ lib, ... }:

{
  options.hello = {
    greeting = lib.mkOption {
      type = lib.types.str;
      default = "Hello, nyantec!";
      description = "Exact greeting to print out";
    };
  };
  
  # ...
}
```
