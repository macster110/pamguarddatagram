function [datagramline, summaryline] = whistledatagramline(tones, fftLength)
%WHISTLEDATAGRAMLINE calculatesa  datgram line for a group of whisltes. 
%   [DATAGRAMLINE, SUMMARYLINE] = WHISTLEDATAGRAMLINE(TONES, FFTLENGTH)
%   calculates a datagram line for a group of tonal sounds detected by the
%   PAMGuard Whistle and Moan Detector module. 

hold on;
contoursdata = zeros(1, 200000); % pre allocate an array 

n=1; 
for i=1:length(tones)
    for j=1:length(tones(i).contour)
        contour=tones(i).contour(j);
        contourwidth=tones(i).contour;

        % want to extract all spectrum bins in which the contour was present
        contourdat=1:contourwidth -contourwidth/2 + contour; 
        
        contoursdata(n:n+length(contourdat)) = contourdat; 
        n=n+length(contourdat)+1; % 
    end
    
    % now extra whistle info. 
    
end

contoursdata=contoursdata(1:n-1); 

%now bin the contours into a histogram
edges = 0:1:fftLength/2; 

datagramline = histcounts(contoursdata, edges); 

for i=1:length(datagramline)
    if (datagramline(i)==0)
        datagramline(i)=NaN; %want blank space where there is no whsitle data. 
    end
end

% now the summary data 
summaryline(1) = length(tones); % the number of tones.
% mean, median and std slope
% mean median and std width


end

