<div align="center">
    <img src="https://git.open-communication.net/secretkookie/nyantec-nix-workshops/-/raw/master/images/logo.png" width="256px"/>
    <h1>Learning nix</h1>
</div>


This repository contains workshop material intended to teach the [`nix`] ecosystem.
That includes: `nix` the tool, `Nix` the language, and `NixOS` the distribution.


## Overview

- Why is nix?
  - What problems does it solve?
  - Core concepts!
    - Immutable store
    - Pure package derivations
    - Lazy expression evaluation
    - Small primer on functional programming
- What is nix (the holy trinity :P)
  - The language (Nix - capitalised)
  - The tools (`nix-*` CLIs)
  - The distribution (NixOS)
  
  
## How to build

To compile the slide decks, you need the following dependencies:

- make
- pandoc


If you have `nix` installed on your system this is as easy as running
`nix-build`.  A `result` symlink will appear with the slide deck that
you can open in a browser.


## Teaching this course

This course is designed to roughly take up a full day of teaching
(meaning ~8 hours including a few breaks).  Depending on your
audience, and available time you may want to split this into a two day
course.

| Component        | Details                                                            |
|------------------|--------------------------------------------------------------------|
| [`introduction`] | Outline the basics of what nix is, why it exists, and how it works |
|                  |                                                                    |
