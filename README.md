<div align="center">
    <img src="https://github.com/spacekookie/nixos-workshops/raw/main/images/logo.png" width="256px"/>
    <h1>Learning nix</h1>
</div>

This repository contains workshop material intended to teach the
[`nix`] ecosystem.  That includes: `nix` the tool, `Nix` the language,
and `NixOS` the distribution.


## Overview

- Why is Nix?
  - What problems does it solve?
  - Nix core concepts
    - Immutable store
    - Pure package derivations
    - Lazy evaluation
    - Reproducibility
  - The Nix ecosystem
- Nix packaging
  - How to build packages
  - Distributing software
- Nix module system
  - Creating system configuration
  - Building module abstractions

| Component             | Details                                                                                                                           |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| [`introduction`]      | Outline the basics of what nix is, why it exists, and how it works                                                                |
| [`nix-modules`]       | Outline of how the NixOS module system works, how to write custom modules, and how to use all this for basic system configuration |
| [`advanced-concepts`] | A set of short explorations of more advanced principles, in package building, module usage, and the Nix tools themselves          |


[`introduction`]: ./introduction/
[`nix-modules`]: ./module-system/
[`advanced-concepts`]: ./advanced-concepts/

  
## How to build

You can compile the slide deck by using Nix by simply running
`nix-build`.  If you don't have Nix installed, you need the following
dependencies:

- make
- pandoc

Then you can simply run `make`.


## Remote trainings available

Are you, or your company interested in learning about how to use Nix
in your workflow?  Already using Nix and want to get new employees up
to speed?  Remote and on-site trainings available! [contact
me](mailto:kookie@spacekookie.de).

This workshop material was created for, and sponsored by [Nyantec]!


## License

This material is licensed under CC-BY-SA 3.0.  A copy of the full
license text is included in this repository.
