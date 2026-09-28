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
export SRCTOP="$root/deps/openssl-3.5.8"
export BLDTOP="$root/deps/openssl-build"
# Selected upstream TLS BIO-pair cases and certificate verification; no socket suite.
export SSL_TESTS="01-simple.cnf.in 02-protocol-version.cnf.in 04-client_auth.cnf.in 09-alpn.cnf.in 13-fragmentation.cnf.in 26-tls13_client_auth.cnf.in"
cd "$BLDTOP"
make_one util/wrap.pl link-utils
# Native Perl selects Windows path/URI rules in the upstream recipes. Regenerate
# only the test wrapper with that interpreter so its absolute require path agrees.
native_perl='C:/Applications/Development/Strawberry/perl/bin/perl.exe'
# Configure ran under MSYS Perl and embedded two absolute utility import paths.
# Windows-form paths work under both Perls. Preserve the generated metadata's
# timestamp so this test-harness adjustment does not invalidate compiled objects.
/usr/bin/perl -e 'my ($f,$from,$to)=@ARGV; my @st=stat($f); open my $in,"<",$f or die $!; local $/; my $s=<$in>; close $in; if ($s =~ s/\Q$from\E/$to/g) { open my $out,">",$f or die $!; print $out $s; close $out; utime $st[8],$st[9],$f or die $!; }' \
    configdata.pm "$root/deps/openssl-3.5.8" "$(cygpath -m "$root/deps/openssl-3.5.8")"
"$native_perl" -I. -Mconfigdata ../openssl-3.5.8/util/dofile.pl \
    -oMakefile ../openssl-3.5.8/util/wrap.pl.in > util/wrap.pl
make_one run_tests "PERL=$native_perl" TESTS="test_verify test_ssl_new"
