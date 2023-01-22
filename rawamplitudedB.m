function [ dB ] = rawamplitudedB( rawAmplitude, vp2p, sens, gain)
%RAWAMPLITUDEDB  Convert a raw amplitude to dB re 1 micropascal based on calibration information held in the AcquisitionController
% 	 * 
% 	 * @param rawAmplitude raw amplitude (should be -1 < rawAmplitude < 1)
% 	 * @return amplitude in dB re 1 uPa.
% 	 */

         constantTerm = sens+gain;
         
         
        % 
% 		/*
% 		 * Need an extra divide by 2 in here since the standard scaling of PAMGUARD
% 		 * data is -1 to +1, so data really needed to be scaled against half
% 		 * the peak to peak voltage. 
% 		 */

		 dB = 20 * log10(rawAmplitude * vp2p /2) - constantTerm;

end

