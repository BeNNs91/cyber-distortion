#pragma once
#include <JuceHeader.h>
#include "PluginProcessor.h"

class CyberDistortionAudioProcessorEditor final : public juce::AudioProcessorEditor
{
public:
    explicit CyberDistortionAudioProcessorEditor(CyberDistortionAudioProcessor&);
    void paint(juce::Graphics&) override;
    void resized() override;
private:
    CyberDistortionAudioProcessor& processor;
    juce::Label title, status;
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(CyberDistortionAudioProcessorEditor)
};
