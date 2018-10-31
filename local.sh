#!/bin/bash

set -xe

for SUITE in stretch buster;
do
    for ARCH in amd64 arm64 armel armhf i386 mips mipsel ppc64el
    do
        ./build.sh -d "skeuchel/multiarch-haskell" -a "$ARCH" -s "$SUITE"
    done
done
