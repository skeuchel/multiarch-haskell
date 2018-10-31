# Welcome to `multiarch-haskell` [![Build Status](https://travis-ci.org/skeuchel/multiarch-haskell.svg?branch=master)](https://travis-ci.org/skeuchel/multiarch-haskell)


## Description

This repository contains the code for creating docker images for Haskell projects with transparent qemu-based usermode emulation of different architectures. These images are mainly designed to be used in compilation, testing and continuous integration rather than deployment.

The images are based on the Debian distribution and contain Debian's system GHC and a set of core libraries in a global package database which are intended to reduce the compilation of build dependencies.


## Usage

The images are available on the Docker Hub registry. Please visit our [Docker Hub](https://hub.docker.com/r/skeuchel/multiarch-haskell/) page to discover the available [tags](https://hub.docker.com/r/skeuchel/multiarch-haskell/tags/) encode different suite and architecture configurations. You can use the provided images directly or derive your own based on them.


## Join in!

Please report bugs or request features via the [github issue tracker](http://github.com/skeuchel/multiarch-haskell/issues) or contribute by opening pull requests for fixes, documentation enhancements, feature request or other improvements.
