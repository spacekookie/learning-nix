---
title: Module system
subtitle: A deep(ish) dive into the nix module system
---

# Overview

---

## Overview

* Modules are implemented via the Nix runtime
* Configuration for _some_ system
  * Not tried to NixOS specifically
* Fundamentally: functions with a specific API

---

## Nix module API

* Modules take an attribute set
  * `options`: nested set of all options declarations
  * `config`: nested set of all option values
  * `lib`, `pkgs`, ... to access utilities
* Modules return an attribute set
  * Three special keys: `options`, `config`, `imports`

---

## Module anatomy

* Function parameters are usually destructured
* Return an attribute set
* Nix runtime will fold attribute sets together


```nix
{ config, lib, ... }:

{
  imports =  [ ./special.nix ];
    
  config.environment.enableDebugInfo = true;
}
```

---

## Module anatomy (!)

* Modules that don't provide option declarations can implicitly
  declare `config`.
* Example: `/etc/nixos/configuration.nix`

```nix
{ config, lib, ... }:

{
  imports = [ ./special.nix ];
  environment.enableDebugInfo = true;
}
```

---

## Quiz: attrset merging

The Nix runtime is responsible for merging attribute sets into a
coherent configuration.

What attribut set is the result?

```nix
{ ... }: { imports = [ ./a.nix ./b.nix ]; }
```

```nix
# a.nix
{ ... }: { config.services.nginx.enable = true; }
```

```nix
# b.nix
{ ... }: { services.nginx = { user = "www"; group = "uwu"; }; }
```

---

## Quiz answer (merging)


```
{ 
  config = {
    services = {
      nginx = {
        enable = true;
        user = "www";
        group = "uwu";
      };
    };
  };
  
  options = {};
}
```

# Using modules

---

## Module sources

* NixOS comes with some modules (`nixpkgs/nixos`)
* Alternative sets exist (e.g. `home-manager`)

<br/>

* A module configures some aspect of a system.
* A module can use other modules.

---

## Example: systemd unit

This configuration uses the systemd nixos module to create a complete
service unit.

```nix
{ config, pkgs, ... }:
{
  systemd.services.helloService = {
    enable = true;
    serviceConfig = {
      ExecStart = ''
        ${pkgs.hello}/bin/hello -g "Hello, nyantec!"
      '';
      Type = "oneshot";
    };
  };
}
```

---

## Example: systemd unit

* Use a deploy mechanism to activate this configuration
  * `sudo nixos-rebuild switch`
  * `nix build -f '<nixpkgs/nixos>' system` && `result/bin/switch-to-configuration switch`

```console
$ sudo systemd status helloService.service
● helloService.service
     Loaded: loaded (/nix/store/.../helloService.service)
     Active: inactive (dead)
$ sudo journalctl -u helloService.service
-- Logs begin at Sat 2020-10-24 16:54:30 CEST, end at Tue 2021-01-19 15:37:37 CET. --
Jan 19 15:36:38 uwu systemd[1]: Starting helloService.service...
Jan 19 15:36:38 uwu hello[1302]: Hello, nyantec!
Jan 19 15:36:38 uwu systemd[1]: helloService.service: Succeeded.
Jan 19 15:36:38 uwu systemd[1]: Finished helloService.service.
```

---

## Example: user management

This configuration creates a user with ssh access.

The NixOS `users` module also ensures that users are created, and
retired (uid remains in-use!) when configuration is removed.

```nix
{ config, ... }:
{
  services.openssh.enable = true;
  users.users.alice = { createHome = true; isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSOwKTQavB5TovmD85RMBw8to5+tfSXfzSAwZXcp+Yg" ];
  };
}
```

---

## Example: user management

* Build with `nix build -f '<nixpkgs/nixos>' system`
* Check result link for outputs
* When activating the configuration `etc` link is replaced on the
  system with the new version

```console
$ ls result/etc/ssh/authorized_keys.d/
jane jane.mode jane.gid jane.uid
$ cat result/etc/ssh/authorized_keys.d/jane
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOSOwKTQavB5TovmD85RMBw8to5+tfSXfzSAwZXcp+Yg
```

---

## Debugging configuration

* Build a NixOS VM from your configuration

```nix
# base.nix: Most minimal system configuration
{ ... }: {
  fileSystems."/".device = "/dev/fake";
  boot.loader.grub.device = "/dev/fake";
}
```

Build and run a qemu VM:

```console
$ nix build -f '<nixpkgs/nixos>' vm -I nixos-config=base.nix
$ result/bin/run-nixos-vm
# qemu goes brrr
```


---

**Find modules**: [https://search.nixos.org/options](https://search.nixos.org/options)

![](module-system/module-railcar.png)


# Writing modules

---

## Short recap

* Everything in nix is an attribute set
* Module system uses some "magic keys"
* Modules are parsed, and merged into one big attrset

Putting all this together we can write our first module!

---

## Writing modules

* Build an API via options
* Provide implementation via `config`
* Use `lib.mkIf` to gate inclusion of the configuration based on an
  `enable` attribute.

```nix
{ config, lib, pkgs, ... }: 

{
  options.services.hello.enable = lib.mkEnableOption "hello service";
  
  config = lib.mkIf config.services.hello.enable {
    systemd.services.helloService = { /* the config from earlier */ };
  };
}
```

---

## Including modules

* Use `imports` key to include new module definitions
* You can use a `NIX_PATH` key to make paths shorter

```nix
{ ... }: 
{ imports = [ <modules/hello.nix> ];
  services.hello.enable = true; }
```

Don't forget to modify your build command

```console
$ ls
my-modules main.nix
$ nix build -f '<nixpkgs/nixos>' vm \
    -I modules=my-modules -I nixos-conf=main.nix
```

---

## Adding option types

* Module type system provided via `lib.types`
* Allows Nix to type-check your configuration
* `builtins` provides some type converters

```nix
{ lib, ... }: {
  options.services.hello = {
    greeting = lib.mkOption {
      type = lib.types.str;
      default = "Hello, nyantec!";
      description = "The greeting to pass to hello(1)";
    };
  };
  
  # ...
}
```

---

## Converting types

* Nix can't "coerce" types
  * No implicit type conversion
* Use builtins such as `builtins.toString` to change types explicitly

```
nix-repl> port = 1312
nix-repl> "${port}"
error: cannot coerce an integer to a string, at (string):1:2

nix-repl> "${toString port}"
"1312"
```


# Advanced types

---

## Submodules

* Many NixOS options rely on submodule types
* Looking at the `railcar` virt module as an example

```nix
{ pkgs, ... }:
{
  services.railcar = {
    containers."test-container" = {
      cmd = "${pkgs.hello}/bin/hello";
    };
  };
}
```

* `containers` is an attrset of submodules
  * Defines available (and required!) options

---

## Submodule type

* You _can_ take a random attribute set as an option
  * No documentation, and no type-checking!
* Instead, use `lib.types.submodule`

```nix
{ lib, ... }:
{
  options.services.hello = {
    enable = lib.mkEnableOption "hello service";
    greeter = lib.mkOption {
      type = lib.types.submodule {
        options = {
          msg = lib.mkOption { type = lib.types.str; };
          pkg = lib.mkOption { type = lib.types.package; };
        }; };
    };
  };
}
```

---

## Submodule type

Using this submodule is no different from using other top-level
options

```nix
{ pkgs, ... }:
{
  # ...
  
  services.hello = {
    enable = true;
    greeter = {
      msg = "Hello, nyantec!";
      pkg = pkgs.hello;
    };
  };
}
```

---

## The `listOf` type

* Sometimes you may want a list of structured attribut sets
* This is how `users.users`,`nginx.virtualHosts`, or
  `railcar.containers` is implemented
  
```nix
{ lib, ... }:
with lib; # incule lib to cut down on boilerplate
{ options.services.hello.greeters = {
    type = with types; listOf (submodule {
      options = {
        msg = lib.mkOption { type = lib.types.
        pkg = lib.mkOption { type = lib.types.package; };
      };
    });
    description = "Set of greeters to print messages for";
  };
}
```

---

## The `listOf` type

```nix
{ pkgs, ... }:
let pkg = pkgs.hello;
in
{
  # ...
  services.hello.greeters = [
    { msg = "Hello, nyantec"; inherit pkg; }
    { msg = "Hello, world!"; inherit pkg; }
  ];
}
```

---

## The `attrsOf` type

* A core component of many complex modules is `attrsOf submodule`
* Take attribute set with keys, and values that are specific submodules

```nix
{ lib, ... }:
with lib; {
  options.services.hello.greeters = {
    type = with types; attrsOf (submodule {
      options = { /* ... */ };
    });
  };
}
```

## The `attrsOf` type

* Declare attribut options as usual

```nix
{ ... }:
{
  # ...
  
  services.hello = {
    enable = true;
    greeters = {
      nyantec = { msg = "Hello, nyantec!"; };
      world = { msg = "Hello, world!"; };
    };
  }
}
```

## The `attrsOf` type

* Module implementation needs to map attributes to desired values

```
{ config, lib, ... }:
let generateUnit = (name: cfg: /* ... */);
in
{
  options.services.hello = { /* ... */ };
  
  config = lib.mkIf config.services.hello.enable {
    systemd.services = (lib.mapAttrs' (name: cfg: 
      lib.nameValuePair "hello-service-${name}" (generateUnit name cfg)));
  };
}
```


# Custom module library

---

## Module library setup

* A module library is a set of files that provide module options
* Create an `all-modules.nix` that itself includes all submodules
  * In nixpkgs: `nixos/module/all-modules.nix`

---

## Namespaces and options

* Nix does not enforce namespaces for files
* Define your own policy and schema for creating modules

An example from my lib, libkookie:

```
libkookie.base = { /* ... */ };
libkookie.server = { /* ... */ };
libkookie.ui = { /* ... */ };
```

---

## Use `$NIX_PATH` for paths

* Don't rely on relative paths between configuration and module
  declaration

```console
#> nixos-rebuild switch -I mymodules=/path/to/config/mymodules ...
```

```nix
{
  imports = [ <mymodules/server/all-modules.nix> ];
}
```

# Questions?
