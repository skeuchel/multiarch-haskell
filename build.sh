#!/bin/bash -e

OPTIND=1
while getopts "a:d:s:" opt; do
    case "$opt" in
    a)  ARCH=$OPTARG
        ;;
    d)  DOCKER_REPO=$OPTARG
        ;;
    s)  SUITE=$OPTARG
        ;;
    esac
done
shift $((OPTIND-1))

TAG="$SUITE-$ARCH"

# Setup packages

## For building haskell packages with cabal
PKGS="gnupg2 git locales dnsutils ca-certificates ghc cabal-install"
#PKGS+=" ghc-doc ghc-prof"

## For building haskell debian packages
#PKGS+=" debhelper haskell-devscripts cdbs cabal-debian dpkg-dev"

## Select haskell libraries

HASKELL_PACKAGES="aeson aeson-pretty ansi-terminal ansi-wl-pprint async
    attoparsec base16-bytestring base64-bytestring bifunctors blaze-builder
    case-insensitive cassava categories cereal clock colour comonad
    contravariant data-default-class distributive dlist entropy exceptions
    extensible-exceptions fingertree free hashable haskell-lexer hostname hspec
    hunit lazysmallcheck lens mmorph monad-control monad-par monad-par-extras
    mtl mwc-random network optparse-applicative parallel parsec3 parsers pipes
    pipes-safe pretty-show primitive profunctors quickcheck-io quickcheck2
    random regex-base regex-posix scientific semigroupoids semigroups split
    statevar statistics stm tagged tasty tasty-hunit tasty-quickcheck
    test-framework test-framework-hunit test-framework-quickcheck2
    transformers-base transformers-compat unix-compat unix-time
    unordered-containers utf8-string vault vector vector-algorithms
    vector-binary-instances void xml zlib"

## Select additional libraries depending on suite
case "$SUITE" in
    buster)
        HASKELL_PACKAGES+=" cabal-doctest call-stack"
        ;&
    stretch)
        HASKELL_PACKAGES+=" aeson-compat base-compat base-orphans criterion generics-sop"
        ;&
    jessie)
        ;;
    *)
        echo "Unknown suite: $SUITE"
        exit 1
        ;;
esac

for pkg in $HASKELL_PACKAGES; do
    PKGS+=" libghc-$pkg-dev"
    #PKGS+=" libghc-$pkg-doc libghc-$pkg-prof"
done

# Prepare the docker file
mkdir -p "$TAG"
cat > "$TAG/Dockerfile" <<EOF
FROM multiarch/debian-debootstrap:$ARCH-$SUITE

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends $PKGS; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
EOF

docker build -t "$DOCKER_REPO:$TAG" "$TAG"

docker run -it --rm "$DOCKER_REPO:$TAG" bash -xc '
    uname -a
    echo
    cat /etc/os-release 2>/dev/null
    echo
    cat /etc/lsb-release 2>/dev/null
    echo
    cat /etc/debian_version 2>/dev/null
    echo
    cabal --version
    echo
    ghc --version
    true
'
