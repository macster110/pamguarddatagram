function [datagramline,summarydata, metadata] = clipdatagramline(clips, fileinfo)
%CLIPDATAGRAMLINE Creates a datagram line and summary data of a group of
%clips.
%   [DATAGRAMLINE,SUMMARYDATA, METADATA] = CLICKDATAGRAMLINE(CLIPS)
%   generates datagram and summary information on a group of clips.
%   DATAGRAM is the line for a datgram and in the case of clips is an
%   average 256 point spectrum of all CLIPS. SUMMARYDATA returns the
%   number of CLIPS in the bin. METADATA holds metadata on the datagram
%   line such as it's name, and twhat SUMMARYDATA variables are. 


fftsize = 256; % the FFT size 
xv = linspace(0,1, fftsize); 

if nargout >= 3
    metadata.datagramname = 'Average spectrum (linear)'; 
    metadata.summarydatnames = {'No. clips'};
end

% the mean FFT,. 
meanfft = zeros(fftsize, 1); 

for i=1:length(clips)
    
    % calculate the mean FFT
    Y = fft(clips(i).wave(:,1));
    
    P2 = abs(Y/fftsize);
    P1 = P2(1:fftsize/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    F = linspace(0,1, length(P1)); 
    
    p1interp = interp1(F, P1, xv); 
    
    meanfft=meanfft+p1interp; 
    
end

%%the datagram line is the mean linear
% datagramline=meanfft/length(clips); 

datagramline=meanfft; 

if (isempty(clips))
    datagramline = nan(fftsize, 1);
end


%% calculate the summary data
summarydata(1)  = length(clips); 

end

