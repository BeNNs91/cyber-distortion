#include "PluginProcessor.h"
#include "PluginEditor.h"

CyberDistortionAudioProcessor::CyberDistortionAudioProcessor()
    : AudioProcessor(BusesProperties()
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)),
      parameters(*this, nullptr, "PARAMETERS", createParameterLayout())
{
}

juce::AudioProcessorValueTreeState::ParameterLayout CyberDistortionAudioProcessor::createParameterLayout()
{
    std::vector<std::unique_ptr<juce::RangedAudioParameter>> params;
    params.push_back(std::make_unique<juce::AudioParameterFloat>(
        juce::ParameterID{"input", 1}, "Input", juce::NormalisableRange<float>(-24.f, 24.f, 0.1f), 0.f));
    params.push_back(std::make_unique<juce::AudioParameterFloat>(
        juce::ParameterID{"drive", 1}, "Drive", juce::NormalisableRange<float>(0.f, 36.f, 0.1f), 0.f));
    params.push_back(std::make_unique<juce::AudioParameterFloat>(
        juce::ParameterID{"output", 1}, "Output", juce::NormalisableRange<float>(-24.f, 24.f, 0.1f), 0.f));
    params.push_back(std::make_unique<juce::AudioParameterBool>(
        juce::ParameterID{"bypass", 1}, "Bypass", false));
    return { params.begin(), params.end() };
}

void CyberDistortionAudioProcessor::prepareToPlay(double, int) {}
void CyberDistortionAudioProcessor::releaseResources() {}

void CyberDistortionAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer, juce::MidiBuffer&)
{
    juce::ScopedNoDenormals noDenormals;
    // Pass-through only. Do not expose drive until actual DSP is implemented.
    // Clear output channels without corresponding input channels.
    for (int channel = getTotalNumInputChannels(); channel < getTotalNumOutputChannels(); ++channel)
        buffer.clear(channel, 0, buffer.getNumSamples());
}

juce::AudioProcessorEditor* CyberDistortionAudioProcessor::createEditor()
{
    return new CyberDistortionAudioProcessorEditor(*this);
}

void CyberDistortionAudioProcessor::getStateInformation(juce::MemoryBlock& destData)
{
    if (auto xml = parameters.copyState().createXml())
        copyXmlToBinary(*xml, destData);
}

void CyberDistortionAudioProcessor::setStateInformation(const void* data, int size)
{
    if (auto xml = getXmlFromBinary(data, size))
    {
        if (xml->hasTagName(parameters.state.getType()))
            parameters.replaceState(juce::ValueTree::fromXml(*xml));
    }
}

// JUCE's plugin wrapper entry point.
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new CyberDistortionAudioProcessor();
}
