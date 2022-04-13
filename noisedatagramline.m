function [datagramline, summarydata, metadata] = noisedatagramline(noisedatas, fileinfo)
%NOISEDATAGRAMLINE Generate a noise line for noise band monitor
%   [DATGRAMLINE, SUMMARYDATA] = NOISEDATAGRAMLINE(NOISEDATAS) creates a
%   noise datagram. The datagram line is the meedian RMS noise measurement

if (isempty(noisedatas))
    datagramline=[];
    summarydata=[]; 
    metadata =[]; 
    return; 
end


if nargout >= 3
    metadata.datagramname = 'Median Noise Band Energy (dB re 1\muPa)';
    metadata.units =  'ANSI S1.11-2004 American National Standard Specification for Octave-Band and Fractional-Octave-Band Analog and Digital Filters.';
    metadata.summarydatanames = 'peak values'; 
end

nbands = noisedatas(1).nBands;
datalinesmean = zeros(length(noisedatas), nbands);
datalinespeak = zeros(length(noisedatas), nbands);



for i=1:length(noisedatas)
    try
%       disp('------------')
%       disp(num2str(noisedatas(i).nBands))
    for j=1:noisedatas(i).nBands
%         disp(num2str(noisedatas(i).noise(1, j)))
        datalinesmean(i,j) = noisedatas(i).noise(1, j);
        datalinespeak(i,j) = noisedatas(i).noise(2, j);
    end
    catch e
        disp(e)
        disp(['nbands ' num2str(nbands)])
    end
end

% pause
% the median is save here
%Note - it is very important to put the dimensions in here otherwise, for
%one column of noise data we get one number 
datagramline = median(datalinesmean, 1); 

% save the peak noise
summarydata = median(datalinespeak,1); 

end

