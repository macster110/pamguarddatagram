function [datagramline, summaryline, metadata] = whistledatagramline(tones, fileinfo, fftLength, sR)
%WHISTLEDATAGRAMLINE calculatesa  datgram line for a group of whisltes.
%   [DATAGRAMLINE, SUMMARYLINE] = WHISTLEDATAGRAMLINE(TONES, FFTLENGTH, SR)
%   calculates a datagram line for a group of tonal sounds detected by the
%   PAMGuard Whistle and Moan Detector module. FFTLENGTH is the FFTLENGTH
%   in bins and SR is the sample rate in samples per second.
%   SUMMARYLINE returns 7 metrics.
% * Total of tones
% * The mean slope . Slope is the change frequency in units of freq/time
%   bins.
% * The median slope; Hz per FFT bin
% * The standard deviation in slope
% * The mean contour width in freq bin units
% * The median contour width
% * The std contour width.

%The size of the fragment to use in no. fft bins. Larger whistles are split
%into equally sized fragments so that averages of frequency, slope etc are
%not biased.
fragsize=5;

hold on;
% pre allocate an arrays
contoursdata = nan(1, 200000);
slopdatas = nan(1, 200000);
cwidthdatas = nan(1,200000);
freqdatas = nan(1,2000000); 

if nargout >= 3
    metadata.datagramname = 'Number of contours';
    metadata.summarydatnames = {'Number contours', 'Mean frequency', 'Median frequency', 'Std Frequency', 'Mean slope', 'Median slope',...
        'Std Slope', 'Mean Contour Width', 'Median contour width', 'Std contour width' };
end

n=1;
nfrag = 1;

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

    contourHz = tones(i).contour*sR/fftLength; %contours in Hz;
    contwidthHz = tones(i).contWidth*sR/fftLength; %contours in Hz;
    smplduration = tones(i).sampleDuration;

    %now to be fair, we want to split the whistles into equally sized
    %fragments. This means that the smaller whisltes do not unfairly
    %influence the average within the bin. Thus we define a fragment size
    %and split larger whistles into a series of fragments.

    nbins=length(contourHz)/fragsize;

%     disp(['Nbins: ' num2str(nbins)])

    for k=1:ceil(nbins)-1
        %get a fragment of the contour

        contourfrag=contourHz((fragsize*(k-1))+1:min(length(contourHz),fragsize*k+1));

        freqdatas(nfrag) = mean(contourfrag);

        slopdatas(nfrag) = (contourfrag(length(contourfrag))-contourfrag(1))/....
                    smplduration/length(contourfrag)/sR;

        cwidthdatas(nfrag) = mean(contwidthHz); 

        nfrag = nfrag+1; 
    end

%         % now extra whistle info .Slope data
%         slope= diff(contourHz); %unit of Hz per fftBin
%         slopdatas(nslope:(nslope+length(slope)-1))= slope;
%         nslope= nslope + length(slope);
% 
%         cwidth= diff(tones(i).contWidth*sR/fftLength); %unit of Hz
%         cwidthdatas(ncwidth:(ncwidth+length(cwidth)-1)) = cwidth;
%         ncwidth= ncwidth + length(cwidth);

end

%trim arrays to get rid of trialling ends.
contoursdata=contoursdata(1:n-1);
slopdatas=slopdatas(1:nfrag-1);
cwidthdatas=cwidthdatas(1:nfrag-1);
freqdatas=freqdatas(1:nfrag-1);


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

summaryline(2) = mean(freqdatas); % mean in slope
summaryline(3) = median(freqdatas); % median in slope
summaryline(4) = std(freqdatas); % std in slope
summaryline(5) = mean(slopdatas); % mean in slope
summaryline(6) = median(slopdatas); % median in slope
summaryline(7) = std(slopdatas); % std in slope
summaryline(8) = mean(cwidthdatas); % mean in contour width
summaryline(9) = median(cwidthdatas); % median in contour width
summaryline(10) = std(cwidthdatas); % std in contour width

% end

