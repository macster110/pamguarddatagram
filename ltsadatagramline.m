function [datagramline, summarydata, metadata] = ltsadatagramline(ltsa_data, fileinfo, hsens , gain, vp2p)
%LTSADATAGRAMLINE Creates a datagram line for a LTSA
%    [DATAGRAM, METADATA] = LTSADATAGRAMLINE(LTSA_DATA, FILEINFO) loads up
%    an LTSA datagram line for LTSA_DATA units.

if (nargin<3)
    hsens=-201;
end

if (nargin<5)
    gain=20;
end

if (nargin<4)
    vp2p=2;
end


sR=fileinfo.moduleHeader.fftHop/fileinfo.moduleHeader.intervalSeconds;
fftlen=fileinfo.moduleHeader.fftLength;


if nargout >= 3
    metadata.datagramname = 'Long Term Spectral Average (linear)';
    metadata.summarydatnames = {''};
    metadata.sR = sR; 
end

n=1; 
for j=1:length(ltsa_data)
    ltsa_channels=getChannels(ltsa_data(j).channelMap);
    for k=1:length(ltsa_channels)
        if (ltsa_channels(k)==ltsa_channels(1)) %use only first channel in group
            %add ltsa data to array.
            if (~isempty(ltsa_data(j).data))
                ltsa_spectrum(:,n)=ltsa_data(j).data(:,k);
                n=n+1;
            else
                disp(['Warning LTSA bin was empty: ' datestr(ltsa_data(j).date)])
            end
        end
    end
end

% sR=moduleheader.moduleHeader.fftHop/moduleheader.moduleHeader.intervalSeconds;
% fftlen=moduleheader.moduleHeader.fftLength;

ltsa_spectrumdB = nan(fftlen/2, 1); 
for i=1:n-1
    %     disp(['Calculating ' num2str(i)])
    ltsa_spectrumdB(:,i)=fftamplitude_2dB(ltsa_spectrum(:,i),sR, fftlen, true,  vp2p, hsens, gain);
end



datagramline=mean(ltsa_spectrumdB, 2);

summarydata = sum(datagramline); 

if (isempty(ltsa_spectrumdB))
    disp('It appears there is no data within time period?');
    return;
end


end

