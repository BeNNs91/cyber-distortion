# CYBER universal VST3 updater - v3
# Close Studio One before running.
# Run: .\build.ps1
# If PowerShell blocks it: powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
# Requires Git, CMake and Visual Studio 2026 C++ tools (or an existing configured CMake build).
# This script updates the ACTIVE Git branch only. It never switches or merges branches.
param([string]$BuildDirectory = 'build-vs2026', [string]$PluginName = '')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

if (!(Test-Path (Join-Path $PSScriptRoot '.git'))) { throw 'No Git checkout found in this folder.' }
$tracked = @(git diff --name-only HEAD)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect local Git changes.' }
if ($tracked.Count -gt 0) {
    throw 'Tracked files have local changes. Commit or stash before updating; your files were not changed.'
}
$branch = (git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) { throw 'No active Git branch.' }
Write-Host "[1/3] Pulling $branch..." -ForegroundColor Cyan
git pull --ff-only origin $branch
if ($LASTEXITCODE -ne 0) { throw 'Git pull failed. Build and installation cancelled.' }

Write-Host '[2/3] Configuring and building Release...' -ForegroundColor Cyan
$buildDir = Join-Path $PSScriptRoot $BuildDirectory
if (!(Test-Path (Join-Path $buildDir 'CMakeCache.txt'))) {
    cmake -S $PSScriptRoot -B $buildDir -G 'Visual Studio 18 2026' -A x64
    if ($LASTEXITCODE -ne 0) { throw 'CMake configure failed; installed plugin unchanged.' }
} else {
    cmake -S $PSScriptRoot -B $buildDir
    if ($LASTEXITCODE -ne 0) { throw 'CMake reconfigure failed; installed plugin unchanged.' }
}
cmake --build $buildDir --config Release --parallel 4
if ($LASTEXITCODE -ne 0) { throw 'Build failed; installed plugin unchanged.' }

# JUCE names this directory <Target>_artefacts/Release/VST3/<Plugin>.vst3.
# Select the bundle generated for the project's PRODUCT_NAME. This prevents
# stale bundles from a previous name (e.g. CYBERMORPH.vst3) being installed.
$cmakeLists = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'CMakeLists.txt') -Raw
if ($PluginName) {
    $expectedName = $PluginName
} else {
    if ($cmakeLists -notmatch '(?m)^\s*PRODUCT_NAME\s+"([^"]+)"') {
        throw 'No quoted PRODUCT_NAME found in CMakeLists.txt. Specify -PluginName explicitly.'
    }
    $expectedName = $Matches[1]
}
$expectedBundle = "$expectedName.vst3"
$bundles = @(Get-ChildItem -LiteralPath $buildDir -Directory -Recurse -Filter '*.vst3' |
    Where-Object { $_.FullName -match '[\\/]Release[\\/]VST3[\\/]' -and $_.FullName -match 'artefacts' -and $_.Name -ieq $expectedBundle })
if ($bundles.Count -ne 1) {
    throw "Expected $expectedBundle in Release VST3 output but found $($bundles.Count). Check PRODUCT_NAME or use -PluginName; nothing installed."
}
$bundle = $bundles[0]
$binary = @(Get-ChildItem -LiteralPath $bundle.FullName -Recurse -File -Filter '*.vst3')
if ($binary.Count -eq 0) { throw 'VST3 binary not found inside bundle; installed plugin unchanged.' }

Write-Host "[3/3] Installing $($bundle.Name)..." -ForegroundColor Cyan
$installRoot = Join-Path $env:CommonProgramFiles 'VST3'
New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
$destination = Join-Path $installRoot $bundle.Name
$staging = Join-Path $installRoot ($bundle.Name + '.installing')
$backup = Join-Path $installRoot ($bundle.Name + '.previous')
if (Test-Path $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
Copy-Item -LiteralPath $bundle.FullName -Destination $staging -Recurse
$hadPrevious = Test-Path $destination
try {
    if ($hadPrevious) {
        if (Test-Path $backup) { Remove-Item -LiteralPath $backup -Recurse -Force }
        Move-Item -LiteralPath $destination -Destination $backup
    }
    Move-Item -LiteralPath $staging -Destination $destination
} catch {
    if ($hadPrevious -and !(Test-Path $destination) -and (Test-Path $backup)) {
        Move-Item -LiteralPath $backup -Destination $destination
    }
    throw
} finally {
    if (Test-Path $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
Write-Host "SUCCESS: $destination" -ForegroundColor Green
Write-Host 'Restart or rescan Studio One to load the updated plugin.'
