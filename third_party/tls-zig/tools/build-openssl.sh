#!/usr/bin/env bash
set -euo pipefail
cd -- "${BASH_SOURCE[0]%/*}/.."
root="$PWD"
export PATH="/c/Applications/Development/Strawberry/c/bin:/usr/bin"
export LC_ALL=C
export HARNESS_JOBS=1
export MAKEFLAGS=-j1
make_one() {
    /c/Applications/Development/Strawberry/c/bin/gmake.exe -j1 \
        'SHELL=C:/Applications/Development/msys64/usr/bin/sh.exe' "$@"
}
mkdir -p deps/openssl-build
cd deps/openssl-build
if [[ ! -f Makefile ]]; then
    /usr/bin/perl ../openssl-3.5.8/Configure mingw64 shared no-quic no-docs \
        --prefix="$(cygpath -m "$root/deps/openssl-install")" \
        --openssldir="$(cygpath -m "$root/deps/openssl-install/ssl")" --libdir=lib
fi
make_one build_libs
make_one apps/openssl.exe test/ssl_test.exe apps/CA.pl apps/tsget.pl
# Install the SDK/runtime without triggering every upstream test executable.
make_one install_dev install_engines install_modules install_ssldirs
cp apps/openssl.exe "$root/deps/openssl-install/bin/openssl.exe"
cp "$root/deps/openssl-3.5.8/LICENSE.txt" "$root/deps/openssl-install/LICENSE.txt"
./apps/openssl.exe version -a
