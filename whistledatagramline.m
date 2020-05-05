function [datagramline, summaryline, metadata] = whistledatagramline(tones, fftLength)
%WHISTLEDATAGRAMLINE calculatesa  datgram line for a group of whisltes.
%   [DATAGRAMLINE, SUMMARYLINE] = WHISTLEDATAGRAMLINE(TONES, FFTLENGTH)
%   calculates a datagram line for a group of tonal sounds detected by the
%   PAMGuard Whistle and Moan Detector module.
%   SUMMARYLINE returns 7 metrics. 
% * Total of tones
% * The mean slope . Slope is the change frequency in units of freq/time
%   bins. 
% * The median slope;
% * The standard deviation in slope
% * The mean contour width in freq bin units
% * The median contour width
% * The std contour width. 

hold on;
% pre allocate an arrays
contoursdata = nan(1, 200000); 
slopdatas = nan(1, 200000);
cwidthdatas = nan(1,200000); 

if nargout >= 3
    metadata.datagramname = 'Number of contours'; 
    metadata.summarydatnames = {'Number contours', 'Mean slope', 'Median slope',...
        'Std Slope', 'Mean Contour Width', 'Median contour width', 'Std contour width' }; 
end

n=1;
nslope = 1;
ncwidth = 1;

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
    
    % now extra whistle info .Slope data
    slope= diff(tones(i).contour);
    slopdatas(nslope:(nslope+length(slope)-1))= slope;
    nslope= nslope + length(slope); 
    
    cwidth= diff(tones(i).contWidth);
    cwidthdatas(ncwidth:(ncwidth+length(cwidth)-1)) = cwidth;
    ncwidth= ncwidth + length(cwidth); 
    
   
end

%trim arrays to get rid of trialling ends. 
contoursdata=contoursdata(1:n-1);
slopdatas=slopdatas(1:nslope-1);
cwidthdatas=cwidthdatas(1:ncwidth-1);

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
summaryline(2) = mean(slopdatas); % mean in slope
summaryline(3) = median(slopdatas); % medina in slope
summaryline(4) = std(slopdatas); % std in slope
summaryline(5) = mean(cwidthdatas); % mean in contour width
summaryline(6) = median(cwidthdatas); % median in contour width
summaryline(7) = std(cwidthdatas); % std in contour width

% end

