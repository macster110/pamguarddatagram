function [s] = plotdatagram(datagram, metadata, varargin)
%PLOTDATAGRAM Plots a datagram
%   S = PLOTDATAGRAM(DATAGRAM, SR) plots a DATAGRAM on frequency time
%   surface. 

usekHz= true;

iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'UsekHz'
            iArg = iArg + 1;
            usekHz = varargin{iArg};
    end
end

sR= metadata.sR;
minmaxtime = metadata.minmaxtime; 

[X, Y] = meshgrid(...
    linspace(minmaxtime(1), minmaxtime(2), length(datagram(1,:))),...
    linspace(0, sR/2, length(datagram(:,1))));

if usekHz
    Y=Y./1000;
end

s = surf(X, Y, 20*log10(datagram), 'EdgeColor', 'none');
ylabel('Frequency (kHz)')
xlabel('Time')
datetick x
xlim([minmaxtime(1), minmaxtime(2)])

freqlimits=[0, sR/2];
if usekHz
    freqlimits=freqlimits/1000.;
end
ylim(freqlimits); 

colormap Jet
colorbar
view([0,90])

end

