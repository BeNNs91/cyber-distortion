# Run from the extracted GitHub artifact ZIP: right-click > Run with PowerShell,
# or launch PowerShell in this folder and run: .\install-vst3.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$bundle = Get-ChildItem -LiteralPath $PSScriptRoot -Directory -Filter '*.vst3' | Select-Object -First 1
if (!$bundle) { throw 'No .vst3 folder next to this installer. Extract the complete ZIP first.' }
$binary = Get-ChildItem -LiteralPath $bundle.FullName -Recurse -File -Filter '*.vst3' | Select-Object -First 1
if (!$binary) { throw 'The extracted VST3 bundle contains no compiled binary.' }
$root = Join-Path $env:ProgramFiles 'Common Files\VST3'
New-Item -ItemType Directory -Force -Path $root | Out-Null
$destination = Join-Path $root $bundle.Name
$staging = Join-Path $root ($bundle.Name + '.installing')
try {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    Copy-Item -LiteralPath $bundle.FullName -Destination $staging -Recurse
    if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
    Move-Item -LiteralPath $staging -Destination $destination
} finally {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
Write-Host "Installed $destination. Restart or rescan Studio One."
