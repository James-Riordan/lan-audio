param([Parameter(ValueFromRemainingArguments=$true)][string[]]$LauncherArguments)
$ErrorActionPreference = 'Stop'
function Get-ArchiveHash([string]$Path) {
    $stream = [IO.File]::OpenRead($Path)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($algorithm.ComputeHash($stream)).Replace('-', '').ToLowerInvariant() }
    finally { $algorithm.Dispose(); $stream.Dispose() }
}
$cache = Join-Path $PSScriptRoot '.lan-audio'
New-Item -ItemType Directory -Force -Path $cache | Out-Null
$lockStream = $null
try {
    $lockStream = [IO.File]::Open((Join-Path $cache 'python.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
    $asset = (Get-Content -Raw -LiteralPath (Join-Path $PSScriptRoot 'tools/bootstrap_assets.json') | ConvertFrom-Json).'python-windows-x86_64'
    $runtime = Join-Path $cache ('python-' + $asset.sha256.Substring(0,16))
    $python = Join-Path $runtime 'python.exe'
    if (-not (Test-Path -LiteralPath $python)) {
        $archive = Join-Path $cache ($asset.sha256 + '.zip')
        if (-not (Test-Path -LiteralPath $archive)) {
            Write-Host 'Preparing a private Python runtime for LAN Audio...'
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $partial = Join-Path $cache ('python-download-' + [Guid]::NewGuid().ToString('N'))
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $asset.urls[0] -OutFile $partial
                if ((Get-Item -LiteralPath $partial).Length -gt $asset.size -or (Get-ArchiveHash $partial) -ne $asset.sha256) { throw 'Python download failed its integrity check.' }
                Move-Item -LiteralPath $partial -Destination $archive
            } finally {
                if (Test-Path -LiteralPath $partial) { Remove-Item -LiteralPath $partial }
            }
        }
        if ((Get-ArchiveHash $archive) -ne $asset.sha256) { throw 'Cached Python archive has changed. Remove that archive and retry.' }
        $stage = Join-Path $cache ('python-stage-' + [Guid]::NewGuid().ToString('N'))
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($archive, $stage)
        Move-Item -LiteralPath $stage -Destination $runtime
    }
} catch {
    Write-Error ('LAN Audio preparation failed: ' + $_.Exception.Message)
    exit 1
} finally {
    if ($null -ne $lockStream) { $lockStream.Dispose() }
}
& $python (Join-Path $PSScriptRoot 'tools/bootstrap.py') @LauncherArguments
exit $LASTEXITCODE
