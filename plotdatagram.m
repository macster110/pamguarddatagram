function [s, c, datagramplt] = plotdatagram(datagram, metadata, varargin)
%PLOTDATAGRAM Plots a datagram
%   [S, C, DATAGRAMPLT] = PLOTDATAGRAM(DATAGRAM, SR) plots a DATAGRAM on
%   frequency time surface. METADATA contains info on the datagram. S is
%   the handle for the surface and C is the handle for the colourbar.
%   DATAGRAMPLT is the plotted surface data,
%
%   [S, C, DATAGRAMPLT]  = PLOTDATAGRAM(DATAGRAM, SR, VARARGIN) adds
%   additional arguments via VARARGIN. These are string, value pairs;
%   * 'UseKhz' - true to plot frequency as kHz;
%   * 'MaxSurfaceSize' - the maximum allowed surface length before
%   interpolation occurs. Interpolation will reduce the surface to this
%   size.
%   * '0isNaN' - true to plot frequency as kHz;
%   * 'plot' - true to plot the calculated surface on a figure. False means
%   the function only returns


usekHz= true; % use kHz
maxsurfacesize = 10000;
zeroisNan = true; % zero values should be coloured as NaN values
plotsurf = true; % true to actually do the plotting.

iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'UsekHz'
            iArg = iArg + 1;
            usekHz = varargin{iArg};
        case 'MaxSurfaceSize'
            iArg = iArg + 1;
            maxsurfacesize = varargin{iArg};
        case '0isNaN'
            iArg = iArg + 1;
            zeroisNan = varargin{iArg};
        case 'plot'
            iArg = iArg + 1;
            plotsurf = varargin{iArg};
    end
end

sR= metadata.sR;
minmaxtime = metadata.minmaxtime;

timebins  = linspace(minmaxtime(1), minmaxtime(2), length(datagram(1,:)));
if (isempty(metadata.freqbins))
    freqbins  = linspace(0, sR/2, length(datagram(:,1)));
else
    freqbins=metadata.freqbins;
end

[X, Y] = meshgrid(...
    timebins,...
    freqbins);

if usekHz
    Y=Y./1000;
end

% first method works but all nan is zero and thus blue whihc indicates that
% there was some data there - nicer if white...
% % re interpolate a surface...
% if (length(timebins)>maxsurfacesize)
%     %// identify indices valid for the 3 matrix
%     idxgood=~(isnan(X) | isnan(Y) | isnan(datagram));
%
%     [Xq, Yq] = meshgrid(...
%         linspace(minmaxtime(1), minmaxtime(2), maxsurfacesize),...
%         linspace(0, sR/2, length(datagram(:,1))));
%
%     %// re-interpolate scattered data (only valid indices) over the "uniform" grid
%     datagramCI = griddata( X(idxgood),Y(idxgood),datagram(idxgood), Xq, Yq );
%
% %     datagram = interp2(X,Y,datagram,Xq,Yq);
%     datagram=datagramCI;
%     X=Xq;
%     Y=Yq;
% end


% re interpolate a surface...
if (length(timebins)>maxsurfacesize)
    % first remove NAN values if duty cycled
    indexrmv =[];
    for i=1:length(datagram(1,:))
        if sum(~isnan(datagram(:,i)))==0
            indexrmv = [indexrmv i];
        end
    end
    
    X(:,indexrmv) = [];
    Y(:,indexrmv) = [];
    datagram(:,indexrmv) = [];
    
    %if still too big interpolate. 
% do not interpoate if noise as this is a log scale and causes all sorts of
% issues. 
    if (length(X(1,:))>maxsurfacesize && metadata.datatype~=3)
        
        [Xq, Yq] = meshgrid(...
            linspace(minmaxtime(1), minmaxtime(2), maxsurfacesize),...
            linspace(0, sR/2, length(datagram(:,1))));
        
        if usekHz
            Yq=Yq./1000;
        end
       
        %// re-interpolate scattered data (only valid indices) over the "uniform" grid
        %     datagramCI = griddata(X,Y,datagram, Xq, Yq );
        
        datagram = interp2(X,Y,datagram,Xq,Yq);
        %         datagram=datagramCI;
        X=Xq;
        Y=Yq;
    end
end


if (plotsurf)
    s = surf(X, Y, datagram, 'EdgeColor', 'none');
    
    if (usekHz)
        ylabel('Frequency (kHz)')
    else
        ylabel('Frequency (Hz)')
    end
    
    xlabel('Time')
    datetick x
    xlim([minmaxtime(1), minmaxtime(2)])
    
    freqlimits=[0, max(freqbins)];
    
    if usekHz
        freqlimits=freqlimits/1000.;
    end
    ylim(freqlimits);
    
    colormap Jet
    c = colorbar;
    c.Label.String = metadata.datagramname;
    view([0,90])
    
    cmap =  colormap('Jet');
    if (zeroisNan)
        cmap(1,:) = [1, 1, 1]; % white
    end
    colormap(cmap);
    
else
    s=[];
    c=[];
end

datagramplt.datagram=datagram;
datagramplt.X = X;
datagramplt.Y = Y;

end

