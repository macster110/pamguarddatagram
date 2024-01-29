function [ dB ] = rawamplitudedB( rawAmplitude, vp2p, sens, gain)
%RAWAMPLITUDEDB  Convert a raw amplitude to dB re 1 micropascal based on
% calibration information held in the AcquisitionController

%The raw amplitude should be between 0 and 2 for peak to peak and 0 to 1
%for RMS measures i.e. 2 is the clip level for peak to peak. 

         constantTerm = sens+gain;
         
         
        % 
% 		/*
% 		 * Need an extra divide by 2 in here since the standard scaling of PAMGUARD
% 		 * data is -1 to +1, so data really needed to be scaled against half
% 		 * the peak to peak voltage. 
% 		 */

		 dB = 20 * log10((rawAmplitude /2) * vp2p) - constantTerm;

end

