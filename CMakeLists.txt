cmake_minimum_required(VERSION 3.22)
project(CyberDistortion VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Install JUCE as a git submodule in the JUCE/ folder before configuring.
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/JUCE/CMakeLists.txt")
    message(FATAL_ERROR "JUCE missing. Run: git submodule add https://github.com/juce-framework/JUCE.git JUCE (if not already present), then git submodule update --init --recursive")
endif()
add_subdirectory(JUCE)

juce_add_plugin(CyberDistortion
    COMPANY_NAME "Cyber Audio"
    BUNDLE_ID "com.cyberaudio.cyberdistortion"
    PLUGIN_MANUFACTURER_CODE Cybr
    PLUGIN_CODE CyDs
    FORMATS VST3 Standalone
    PRODUCT_NAME "CYBER DISTORTION"
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    IS_MIDI_EFFECT FALSE
    COPY_PLUGIN_AFTER_BUILD FALSE)

juce_generate_juce_header(CyberDistortion)

target_sources(CyberDistortion PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginProcessor.h
    Source/PluginEditor.cpp
    Source/PluginEditor.h)

target_compile_definitions(CyberDistortion PUBLIC
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0)

target_link_libraries(CyberDistortion PRIVATE
    juce::juce_audio_utils
    juce::juce_dsp
    PUBLIC juce::juce_recommended_config_flags
           juce::juce_recommended_lto_flags
           juce::juce_recommended_warning_flags)
