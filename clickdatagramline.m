function [datagramline,summarydata] = clickdatagramline(clicks)
%CLICKDATAGRAMLINE Creates a datagram line and summary data of a group of
%clicks.
%   [DATAGRAMLINE,SUMMARYDATA] = CLICKDATAGRAMLINE(CLICKS, DATABIN)
%   generates datagram and summary information on a group of clicks.
%   DATAGRAM is the line for a datgram and in the case of clicks is an
%   average 256 point spectrum of all CLICKS. SUMMARYDATA returns the
%   number of unclassified and classified clicks in a bin and the mean,
%   median, std of recieved amplitude in linear units (-1 to 1).

fftsize = 256;

nClassifiers  = 5; %maximum number of classifiers to look for e.g. any type from 1 to nClassifiers 

meanfft = zeros(fftsize/2+1, 1); 

ppamp = zeros(length(clicks), 1); 
for i=1:length(clicks)
    
    % calculate the mean FFT
    Y = fft(clicks(i).wave(:,1), fftsize);
    
    P2 = abs(Y/fftsize);
    P1 = P2(1:fftsize/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    meanfft=meanfft+P1; 
    
    %add to summary data
    ppamp(i) = diff(minmax(clicks(i).wave(:,1))); 
    
end

%%the datagram line is the mean linear
datagramline=meanfft/length(clicks); 

types = [clicks.type];

%% calculate the summary data
summarydata(1)  = mean(ppamp); 
summarydata(2) = median(ppamp); 
summarydata(3) = std(ppamp); 

%% now classification ratio
numclssfd = sum(types==0);

summarydata(4) = numclssfd; 

for i=1:nClassifiers
    summarydata(4+i) = sum(types==i);
end

end

