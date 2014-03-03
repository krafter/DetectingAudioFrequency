
#ifndef ShazamTest_FFTHelper_h
#define ShazamTest_FFTHelper_h




#import <Accelerate/Accelerate.h>
#include <MacTypes.h>


typedef struct FFTHelperRef {
    FFTSetup fftSetup;
    COMPLEX_SPLIT complexA;
    Float32 *outFFTData;
    Float32 *invertedCheckData;
} FFTHelperRef;


FFTHelperRef * FFTHelperCreate(long numberOfSamples);
Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 *timeDomainData, long numSamples);
void FFTHelperRelease(FFTHelperRef *fftHelper);


#endif
