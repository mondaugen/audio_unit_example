// Example signal chain for testing Audio Unit

#include <stdlib.h>
#include <stdio.h>
#include <string.h> 
#include <CoreAudio/CoreAudioTypes.h>
#include <AudioToolbox/AudioToolbox.h> 
#include <CoreFoundation/CoreFoundation.h> 
#include <AVFoundation/AVFoundation.h>
#include "FilterDemo.h" 
#include "FilterDSPKernel.hpp"

static volatile int done = 0;

void mysig (int signum) { done=1; }

// TODO: Make this prettier by putting in a class or something
static AVAudioUnit *afilter = NULL;

int main (void)
{
    AVAudioEngine *aengine = [[AVAudioEngine alloc] init];
    AVAudioPlayerNode *aplayer = [[AVAudioPlayerNode alloc] init];
    NSURL *fileurl = [NSURL fileURLWithPath:@"./drumLoop.wav"];
    NSError *err = [NSError alloc];
    AVAudioFile *afile = [[AVAudioFile alloc] initForReading:fileurl error:&err];
    [aengine attachNode:aplayer];
    AVAudioTime *atime = [AVAudioTime timeWithHostTime:0];
    [aplayer scheduleFile:afile atTime:nil completionHandler:NULL];
    // Add the filter
    AudioComponentDescription componentDescription = {
        .componentType = kAudioUnitType_Effect,
        .componentSubType = 0x666c7472 /*'fltr'*/,
        .componentManufacturer = 0x44656d6f /*'Demo'*/,
        .componentFlags = 0,
        .componentFlagsMask = 0
    };
    /*
       Register our `AUAudioUnit` subclass, `AUv3FilterDemo`, to make it able
       to be instantiated via its component description.

       Note that this registration is local to this process.
       */
    [AUAudioUnit registerSubclass:AUv3FilterDemo.self
                             asComponentDescription:componentDescription
                             name:@"Demo: Local FilterDemo"
                             version:420];
    // Instantiate a filter, have to wait to complete
    [AVAudioUnit instantiateWithComponentDescription:componentDescription  
                 options:kAudioComponentInstantiation_LoadInProcess
                 completionHandler: ^ void (AVAudioUnit *au, NSError *err) {
                     if (!au || !au.audioUnit) {
                         printf("Error instantiating filter\n"); exit(-1);
                     }
                     afilter = au;
                     // make sure not added to an engine
                     [afilter.engine detachNode:afilter];
                     // add to engine
                     [aengine attachNode:afilter];
                     // connect player to filter
                     [aengine connect:aplayer to:afilter format:afile.processingFormat];
                     // connect filter to output
                     [aengine connect:afilter to:aengine.outputNode format:afile.processingFormat];
                     // set parameter
                     AUParameter *param = [au.AUAudioUnit.parameterTree parameterWithAddress:FilterParamCutoff];
                     [param setValue:500.];
                     if ([aengine startAndReturnError:&err]==NO) { printf("Error starting engine.\n"); exit(-1); }
                     [aplayer play];
                     signal(SIGINT,mysig);
                     while (!done);
                     exit(0);
                 }];
//    while (!afilter);
}
