function [datagramline,summarydata, metadata] = clickdatagramline(clicks, fileinfo, metadata)
%CLICKDATAGRAMLINE Creates a datagram line and summary data of a group of
%clicks.
%   [DATAGRAMLINE,SUMMARYDATA, METADATA] = CLICKDATAGRAMLINE(CLICKS)
%   generates datagram and summary information on a group of clicks.
%   DATAGRAM is the line for a datgram and in the case of clicks is an
%   average 256 point spectrum of all CLICKS. SUMMARYDATA returns the
%   number of unclassified and classified clicks in a bin and the mean,
%   median, std of recieved amplitude in linear units (-1 to 1). METADATA
%   holds metadata on the datagram line such as it's name, and twhat
%   SUMMARYDATA variables are.

fftsize = 256;

nClassifiers  = 5; %maximum number of classifiers to look for e.g. any type from 1 to nClassifiers

if nargout >= 3
    metadata.datagramname = 'Average spectrum (linear)';
    metadata.summarydatnames = {'Mean amplitude (linear -1 -> 1)', 'Median amplitude (linear -1 -> 1)', ...
        'Std amplitude (linear -1 -> 1)', 'No. unclassified clicks', 'No. classified clicks',...
        'No. clicks classiifcation type = 1',...
        'No. clicks classiifcation type = 2',...
        'No. clicks classiifcation type = 3',...
        'No. clicks classiifcation type = 4',...
        'No. clicks classiifcation type = 5'};
end

meanfft = zeros(fftsize/2+1, 1);

ppamp = zeros(length(clicks), 1);
for i=1:length(clicks)
    if (~isempty(clicks(i).wave))
        % calculate the mean FFT
        Y = fft(clicks(i).wave(:,1), fftsize);
        
        P2 = abs(Y/fftsize);
        P1 = P2(1:fftsize/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        meanfft=meanfft+P1;
        
        %add to summary data
        ppamp(i) = diff(minmax(clicks(i).wave(:,1)));
    end
end

%%the datagram line is the mean linear
%DO NOT DIVIDE BY THE LENGTH OF CLICKS. 
datagramline=meanfft;

types = [clicks.type];

%% calculate the summary data
summarydata(1)  = mean(ppamp);
summarydata(2) = median(ppamp);
summarydata(3) = std(ppamp);

%% now classification ratio
numunclssfd = sum(types==0);
numclssfd = sum(types~=0);

summarydata(4) = numunclssfd;
summarydata(5) = numclssfd;

for i=1:nClassifiers
    summarydata(5+i) = sum(types==i);
end

end

