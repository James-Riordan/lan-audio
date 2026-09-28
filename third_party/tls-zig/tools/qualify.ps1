param(
    [string]$Zig = 'C:/Applications/Development/zig/zig-x86_64-windows-0.17.0-dev.1859+dcceb318e/zig.exe',
    [string]$BuildRunner = ''
)
$ErrorActionPreference = 'Stop'
$tlsRoot = Split-Path -Parent $PSScriptRoot
Push-Location $tlsRoot
$tlsPreviousPath = $env:PATH
$tlsPreviousCache = $env:ZIG_GLOBAL_CACHE_DIR
$tlsPreviousBin = $env:TLS_OPENSSL_BIN
$tlsPreviousConf = $env:OPENSSL_CONF
$tlsPreviousModules = $env:OPENSSL_MODULES
try {
    $env:TLS_OPENSSL_BIN = Join-Path $tlsRoot 'deps/openssl-install/bin'
    $env:PATH = "$env:TLS_OPENSSL_BIN;$env:PATH"
    $env:OPENSSL_CONF = Join-Path $tlsRoot 'deps/openssl-install/ssl/openssl.cnf'
    $env:OPENSSL_MODULES = Join-Path $tlsRoot 'deps/openssl-install/lib/ossl-modules'
    $env:ZIG_GLOBAL_CACHE_DIR = Join-Path $tlsRoot '.zig-global-cache'
    if ((& $Zig version) -ne '0.17.0-dev.1859+dcceb318e') { throw 'Unqualified Zig compiler' }
    if (-not (Test-Path -LiteralPath "$env:TLS_OPENSSL_BIN/libssl-3-x64.dll")) { throw 'Build the private OpenSSL dependency first' }
    $tlsLock = Get-Content -Raw backend-lock.json | ConvertFrom-Json
    if ($tlsLock.backend -ne 'OpenSSL 3.5.8 25 Aug 2026' -or
        $tlsLock.sdk_root -ne 'deps/openssl-install' -or
        $tlsLock.zig -ne '0.17.0-dev.1859+dcceb318e' -or
        $tlsLock.target -ne 'x86_64-windows-gnu') {
        throw 'Backend lock metadata does not match this qualification profile'
    }
    & python tools/verify-backend.py
    if ($LASTEXITCODE -ne 0) { throw 'Private SDK verification failed; preserve the lock and investigate the mismatch' }
    New-Item -ItemType Directory -Force evidence | Out-Null
    foreach ($tlsStep in @('test','host-test','interop','example')) {
        if ($BuildRunner) {
            $tlsCompilerDir = Split-Path -Parent $Zig
            & $BuildRunner build "--zig-lib=$tlsCompilerDir/lib" "--zig=$Zig" "--global-cache=$env:ZIG_GLOBAL_CACHE_DIR" --seed=0 $tlsStep -j1 --summary all 2>&1 |
                Tee-Object -FilePath "evidence/qualification-$tlsStep.log"
        } else {
            & $Zig build $tlsStep -j1 --summary all 2>&1 |
                Tee-Object -FilePath "evidence/qualification-$tlsStep.log"
        }
        if ($LASTEXITCODE -ne 0) { throw "Qualification failed: $tlsStep (exit $LASTEXITCODE)" }
    }
    & $Zig fmt --check build.zig src tests examples
    if ($LASTEXITCODE -ne 0) { throw 'Formatting check failed' }
} finally {
    $env:PATH = $tlsPreviousPath
    $env:ZIG_GLOBAL_CACHE_DIR = $tlsPreviousCache
    $env:TLS_OPENSSL_BIN = $tlsPreviousBin
    $env:OPENSSL_CONF = $tlsPreviousConf
    $env:OPENSSL_MODULES = $tlsPreviousModules
    Pop-Location
}
