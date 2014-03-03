DetectingAudioFrequency
=======================

An example iPhone project to show how to detect frequency of captured microphone audio.
This project illustrates this stackoverflow answer: http://stackoverflow.com/questions/11686625/get-hz-frequency-from-audio-stream-on-iphone/19966776#19966776

This project uses Apple's Accelerate.framework to perform CPU consuming digital signal processing. 


1. Generate a specific frequency using Audacity for example.
2. Run the project, play the sound. 


The main stuff that does FFT is inside FFTHelper.mm. 

