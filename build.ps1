# CYBER local updater: git pull (fast-forward only), build Release VST3, install to Studio One.
# Run from PowerShell in the repository: .\build.ps1
# Requires Git, CMake, Visual Studio 2022 C++ build tools; Administrator access for system VST3 installation.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (!(Test-Path '.git')) { throw 'Run this script from a cloned Git repository.' }
$changes = @(git status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Git status failed.' }
if ($changes.Count -gt 0) { throw 'Uncommitted changes detected. Commit or stash them first; nothing has been pulled or installed.' }
Write-Host '[1/3] Pulling the current branch (fast-forward only)...'
git pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'Git pull failed. Existing plugin was not touched.' }
Write-Host '[2/3] Configuring and building Release VST3...'
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed. Existing plugin was not touched.' }
cmake --build build --config Release --target CyberDistortion_VST3 --parallel 4
if ($LASTEXITCODE -ne 0) { throw 'Build failed. Existing plugin was not touched.' }
$release = Join-Path $PSScriptRoot 'build/CyberDistortion_artefacts/Release/VST3'
if (!(Test-Path -LiteralPath $release)) { throw "VST3 output not found: $release" }
$bundle = Get-ChildItem -LiteralPath $release -Directory -Filter '*.vst3' | Select-Object -First 1
if (!$bundle) { throw 'No built .vst3 bundle found.' }
$binary = Get-ChildItem -LiteralPath $bundle.FullName -Recurse -File -Filter '*.vst3' | Select-Object -First 1
if (!$binary) { throw 'VST3 binary missing; old installation untouched.' }
Write-Host '[3/3] Installing VST3 for Studio One...'
$installRoot = Join-Path $env:ProgramFiles 'Common Files\VST3'
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
$destination = Join-Path $installRoot $bundle.Name
$staging = Join-Path $installRoot ($bundle.Name + '.installing')
$backup = Join-Path $installRoot ($bundle.Name + '.previous')
if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
Copy-Item -LiteralPath $bundle.FullName -Destination $staging -Recurse
if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
$hadPrevious = Test-Path -LiteralPath $destination
try {
    if ($hadPrevious) { Move-Item -LiteralPath $destination -Destination $backup }
    Move-Item -LiteralPath $staging -Destination $destination
    if (Test-Path -LiteralPath $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
} catch {
    if ($hadPrevious -and !(Test-Path -LiteralPath $destination) -and (Test-Path -LiteralPath $backup)) {
        Move-Item -LiteralPath $backup -Destination $destination
    }
    throw
} finally {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
Write-Host "SUCCESS: $destination"
Write-Host 'Restart Studio One or rescan plugins to test.'
