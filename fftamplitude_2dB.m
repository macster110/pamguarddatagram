function [ dB ] = fftamplitude_2dB(  fftAmplitude,  sampleRate,  fftLength,  isSquared, vp2p, hsens, gain )
%FFTAMPLITUDE_2DB Convert the amplitude of fft data into a spectrum level measurement in
%dB re 1 micropacal / sqrt(Hz).
%
% 	 * Convert the amplitude of fft data into a spectrum level measurement in
% 	 * dB re 1 micropacal / sqrt(Hz).
% 	 * @param fftAmplitude magnitude of the fft data (not the magnitude squared !)
% 	 * @param channel channel number
% 	 * @param sampleRate sample rate - this needs to be sent, since this function is
% 	 * often called from decimated data, in which case the sample rate will be different.
% 	 * @param fftLength length of the FFT (needed for Parsevals correction)
% 	 * @param isSquared is magnitude squared (in which case sqrt will be taken).
% 	 * @param fast use fast calculation (after call to prepareFastAmplitudeCalculation(...).
% 	 * @return spectrum level amplitude.

sqrt2 = sqrt(2.0);

if (isSquared)
    fftAmplitude = sqrt(fftAmplitude);
end

fftAmplitude = fftAmplitude/fftLength;
% allow for negative frequencies
fftAmplitude = fftAmplitude*sqrt2;
% thats the energy in an nHz bandwidth. also need bandwidth correction to get
% to spectrum level data
binWidth = sampleRate / fftLength;
fftAmplitude =fftAmplitude /sqrt(binWidth);


dB = rawamplitudedB(fftAmplitude, vp2p, hsens, gain);


end

