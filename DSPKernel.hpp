/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Utility code to manage scheduled parameters in an audio unit implementation.
*/

#ifndef DSPKernel_h
#define DSPKernel_h

#include <AudioToolbox/AudioToolbox.h>
#include <algorithm>

//typedef AUScheduleMIDIEventBlock AUScheduleMIDIEventBlock;

template <typename T>
T clamp(T input, T low, T high) {
	return std::min(std::max(input, low), high);
}

// Put your DSP code into a subclass of DSPKernel.
class DSPKernel {
public:
	virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
	virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;
	
	// Override to handle MIDI events.
	virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) {}
	
	void processWithEvents(AudioTimeStamp const* timestamp, AUAudioFrameCount frameCount, AURenderEvent const* events, AUScheduleMIDIEventBlock midiOut);

private:
	void handleOneEvent(AURenderEvent const* event);
	void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const*& event, AUScheduleMIDIEventBlock midiOut);
};

#endif /* DSPKernel_h */
