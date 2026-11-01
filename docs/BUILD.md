# CYBER DISTORTION — Windows build

Requirements: Git, CMake 3.22+, Visual Studio 2022 C++ Build Tools (Desktop development with C++), internet access for the first configure.

## Clone the in-progress branch

```powershell
git clone --branch feature/initial-juce-scaffold https://github.com/BeNNs91/cyber-distortion.git
cd cyber-distortion
```

## Configure and build

Open **Developer PowerShell for VS 2022**:

```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release
```

JUCE **8.0.16-security** is automatically fetched during CMake configure. No separate submodule step is needed.

Expected artifacts: `build/CyberDistortion_artefacts/Release/Standalone/` and `build/CyberDistortion_artefacts/Release/VST3/`.

To update an existing clone:

```powershell
git switch feature/initial-juce-scaffold
git pull
```

## Current limitations

The plugin is pass-through only and the GUI is a placeholder. Distortion, gain, EQ, oversampling, filtering, visual analysis and master clipper have **not yet** been implemented. Confirm the standalone launches and loads without issues before continuing DSP.
