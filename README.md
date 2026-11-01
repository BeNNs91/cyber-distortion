# CYBER DISTORTION

A compact, character-focused distortion audio plugin, part of the Cyber audio plugin family.

## Development status

Initial project setup. JUCE/C++ VST3 and standalone builds are planned. Features below are requirements, **not yet implemented**.

## Core signal path (proposed)

Input gain → pre-drive EQ → HP/LP → selectable distortion engine → post-shaping → dry/wet blend → output gain → master clipper → meters.

The exact locations of oversampling and filters will be validated during DSP development. Intentional digital aliasing must remain possible even when oversampling is enabled elsewhere.

## Requirements

- Dark, compact Cyber UI: charcoal, orange accents, small consistent controls, resizable layout.
- Input/output gain and metering; A/B, undo/redo, bypass, preset management.
- Ten original distortion types plus Digital Aliasing: Clipping, Soft Clip, Hard Clip, Tape, Tube, Saturation, Fuzz, Foldback, Bit Crusher, Diode, Digital Aliasing (11 total).
- Each distortion algorithm has its own expandable **Advanced** controls; shared main controls remain consistent.
- Drive with optional envelope follower (amount, attack, release), with future modulation of algorithm-specific parameters.
- Pre-drive EQ (low, mid, high), high-pass and low-pass filters.
- Center waveform and spectrum visualization with before/after comparison and highlighted distortion-generated frequency content (visual approximation, not a claim of precise source isolation).
- Oversampling: None, 2x, 4x, 8x; selectable wet/dry mix.
- Tone, bias, presence, width, dynamics shaping controls (behavior to be defined per algorithm).
- Master output clipper: **Off / Soft / Hard**, using the small shared Cyber selector.
- Low CPU use, predictable latency, parameter automation and state recall.

### Distortion advanced controls (initial proposals)

| Algorithm | Advanced controls |
| --- | --- |
| Clipping | Threshold, shape, symmetry |
| Soft Clip | Knee, curve, bias |
| Hard Clip | Threshold, symmetry, ceiling |
| Tape | Saturation, wow/flutter, hysteresis |
| Tube | Bias, warmth, even/odd harmonics |
| Saturation | Curve, colour, harmonics |
| Fuzz | Gate, bias, texture |
| Foldback | Fold threshold, folds, symmetry |
| Bit Crusher | Bit depth, sample-rate reduction, dither |
| Diode | Bias, asymmetry, character |
| Digital Aliasing | Downsampling, alias amount, foldover, jitter, optional anti-alias filtering |

## Milestones

1. Buildable JUCE VST3 + standalone project, basic window and bypass-safe audio path.
2. Input/drive/output controls, gain staging and peak meters.
3. Hard/soft clip engines and shared master clipper.
4. Other algorithms with individual advanced settings.
5. Envelope follower, EQ, filters, oversampling and mix.
6. Spectrum/waveform visualizer, polish and automated DSP tests.

## Local setup (Windows / VS Code)

Prerequisites: Git, CMake, Visual Studio C++ build tools, and the JUCE source as a Git submodule.

Once the scaffold is merged, clone recursively and configure with CMake (see scaffold branch). Build outputs and Visual Studio generated files are not committed.
