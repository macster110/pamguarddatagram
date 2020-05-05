function [datagramline, summaryline] = whistledatagramline(tones, fftLength)
%WHISTLEDATAGRAMLINE calculatesa  datgram line for a group of whisltes.
%   [DATAGRAMLINE, SUMMARYLINE] = WHISTLEDATAGRAMLINE(TONES, FFTLENGTH)
%   calculates a datagram line for a group of tonal sounds detected by the
%   PAMGuard Whistle and Moan Detector module.

hold on;
contoursdata = nan(1, 200000); % pre allocate an array

n=1;
for i=1:length(tones)
    for j=1:length(tones(i).contour)
        contour=tones(i).contour(j);
        contourwidth=tones(i).contWidth(j);
        
        % want to extract all spectrum bins in which the contour was present
        if (contourwidth~=0)
            contourdat=(1:contourwidth) - contourwidth/2 + contour;
        else
            contourdat = contour;
        end
        
        if (~isempty(contourdat))
            contoursdata(n:(n+length(contourdat)-1)) = contourdat;
            n=n+length(contourdat); %
        end
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


% end

