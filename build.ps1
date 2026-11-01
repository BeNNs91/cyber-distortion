# Build the JUCE VST3 and copy it into the system VST3 directory.
# Close Studio One before running. From this repository: .\build.ps1
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$installRoot = Join-Path $env:ProgramFiles 'Common Files\VST3'
Write-Host 'Configuring CyberDistortion...'
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed. Existing plugin was not touched.' }
cmake --build build --config Release --target CyberDistortion_VST3 --parallel 4
if ($LASTEXITCODE -ne 0) { throw 'Build failed. Existing plugin was not touched.' }
$release = Join-Path $PSScriptRoot 'build/CyberDistortion_artefacts/Release/VST3'
$bundle = Get-ChildItem -LiteralPath $release -Directory -Filter '*.vst3' | Select-Object -First 1
if (!$bundle) { throw "Built VST3 bundle not found in $release" }
$binary = Get-ChildItem -LiteralPath $bundle.FullName -Recurse -File -Filter '*.vst3' | Select-Object -First 1
if (!$binary) { throw 'Built VST3 binary missing. Existing plugin was not touched.' }
New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
$destination = Join-Path $installRoot $bundle.Name
$staging = Join-Path $installRoot ($bundle.Name + '.installing')
try {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
    Copy-Item -LiteralPath $bundle.FullName -Destination $staging -Recurse
    if (Test-Path -LiteralPath $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
    Move-Item -LiteralPath $staging -Destination $destination
} finally {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
Write-Host "Installed $destination. Restart or rescan Studio One."
