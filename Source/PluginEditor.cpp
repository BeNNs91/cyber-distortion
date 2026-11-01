#include "PluginEditor.h"

CyberDistortionAudioProcessorEditor::CyberDistortionAudioProcessorEditor(CyberDistortionAudioProcessor& p)
    : AudioProcessorEditor(&p), processor(p)
{
    title.setText("CYBER DISTORTION", juce::dontSendNotification);
    title.setColour(juce::Label::textColourId, juce::Colour::fromRGB(255, 120, 30));
    title.setFont(juce::Font(26.0f, juce::Font::bold));
    addAndMakeVisible(title);

    status.setText("Initial scaffold  |  Audio pass-through  |  DSP coming next", juce::dontSendNotification);
    status.setColour(juce::Label::textColourId, juce::Colours::lightgrey);
    status.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(status);
    setSize(700, 300);
}

void CyberDistortionAudioProcessorEditor::paint(juce::Graphics& g)
{
    g.fillAll(juce::Colour::fromRGB(20, 22, 27));
    g.setColour(juce::Colour::fromRGB(255, 120, 30));
    g.drawRect(getLocalBounds().reduced(8), 2);
}

void CyberDistortionAudioProcessorEditor::resized()
{
    title.setBounds(30, 30, getWidth() - 60, 55);
    status.setBounds(30, getHeight() / 2 - 20, getWidth() - 60, 40);
}
