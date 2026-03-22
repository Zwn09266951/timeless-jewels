Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$logPath = Join-Path $PSScriptRoot 'codex-launch-dev.log'

$nodeRoot = Get-ChildItem 'E:\Path of Exile' -Directory |
  Where-Object { Test-Path (Join-Path $_.FullName 'node-portable\node-v20.18.0-win-x64\npm.cmd') } |
  Select-Object -First 1 -ExpandProperty FullName

if (-not $nodeRoot) {
  throw 'Portable Node.js was not found under E:\Path of Exile.'
}

$nodeDir = Join-Path $nodeRoot 'node-portable\node-v20.18.0-win-x64'
$env:Path = "$nodeDir;$env:Path"

Set-Location "$PSScriptRoot\frontend"

$wasmPath = ".\static\calculator.wasm"
if (-not (Test-Path $wasmPath)) {
  Write-Host "calculator.wasm missing, downloading..."
  Invoke-WebRequest -Uri "https://vilsol.github.io/timeless-jewels/calculator.wasm" -OutFile $wasmPath
}

$needsInstall = -not (Test-Path ".\node_modules")
$tsVersion = ""
if (-not $needsInstall) {
  try {
    $tsVersion = & (Join-Path $nodeDir 'node.exe') -p "require('./node_modules/typescript/package.json').version"
  } catch {
    $tsVersion = ""
  }
}

if ($needsInstall -or $tsVersion.Trim() -ne "5.2.2") {
  Write-Host "Installing frontend dependencies..."
  & (Join-Path $nodeDir 'npm.cmd') install --legacy-peer-deps
  & (Join-Path $nodeDir 'npm.cmd') install --save-dev typescript@5.2.2 --legacy-peer-deps --force
}

"[$(Get-Date -Format s)] Starting Vite dev server" | Out-File -FilePath $logPath -Encoding utf8
& (Join-Path $nodeDir 'npm.cmd') run dev -- --host 127.0.0.1 --port 5173 2>&1 | Tee-Object -FilePath $logPath -Append
