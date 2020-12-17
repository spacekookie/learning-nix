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

* `{ config, lib, ... }:` is a deconstructed function header
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


# Writing modules
