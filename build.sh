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

################################################################################
# Packages
################################################################################

# For building haskell packages with cabal
PKGS="alex ca-certificates cabal-install curl dnsutils ghc git gnupg2 happy \
hscolour locales pkg-config wget"

# For building haskell debian packages
#PKGS+=" ghc-doc ghc-prof debhelper haskell-devscripts cdbs cabal-debian dpkg-dev"

# Select haskell libraries

HASKELL_JESSIE_PACKAGES="aeson aeson-pretty ansi-terminal ansi-wl-pprint async
attoparsec base16-bytestring base64-bytestring bifunctors blaze-builder
case-insensitive cassava categories cereal clock colour comonad conduit
contravariant data-default-class deepseq directory distributive dlist entropy
exceptions extensible-exceptions fast-logger fingertree free hashable
haskell-lexer hostname hspec hunit lazysmallcheck lens mmorph monad-control
monad-logger monad-logger mtl mwc-random network optparse-applicative parallel
parsec3 parsers pipes pipes-safe pointed pretty-show primitive profunctors
quickcheck-io quickcheck2 random regex-base regex-posix scientific semigroupoids
semigroups split statevar stm syb tagged tasty tasty-hunit tasty-quickcheck
test-framework test-framework-hunit test-framework-quickcheck2 transformers-base
transformers-compat unix-compat unix-time unordered-containers utf8-string vault
vector vector-algorithms vector-binary-instances void xml zlib"

HASKELL_STRETCH_PACKAGES="base-orphans criterion fixed generics-sop half"

HASKELL_BUSTER_PACKAGES="cabal-doctest call-stack"

HASKELL_PACKAGES=""
## Select additional libraries depending on suite
case "$SUITE" in
    buster)  HASKELL_PACKAGES+=" $HASKELL_BUSTER_PACKAGES"  ;& # Fall through
    stretch) HASKELL_PACKAGES+=" $HASKELL_STRETCH_PACKAGES" ;& # Fall through
    jessie)  HASKELL_PACKAGES+=" $HASKELL_JESSIE_PACKAGES"  ;;
    *)
        echo "Unknown suite: $SUITE"
        exit 1
        ;;
esac

for pkg in $HASKELL_PACKAGES; do
    PKGS+=" libghc-$pkg-dev"
    #PKGS+=" libghc-$pkg-doc libghc-$pkg-prof"
done

################################################################################
# Dockerfile
################################################################################

mkdir -p "$TAG"
cat > "$TAG/Dockerfile" <<EOF
FROM multiarch/debian-debootstrap:$ARCH-$SUITE

# Ensure locale is set during image build
ENV LANG            C.UTF-8

# Install packages
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends $PKGS; \
    rm -rf /var/lib/apt/lists/*

# Generate locale en_US.UTF-8 and set it
RUN set -ex; \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Update the PATH variable to include binaries built by cabal and local binaries
ENV PATH=/root/.cabal/bin:/root/.local/bin:$PATH
EOF

################################################################################
# Build
################################################################################

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
