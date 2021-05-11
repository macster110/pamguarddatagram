function [s, poldatagramsurf, hLeg, c] = polarplotdatagram(datagram, metadata, varargin)
%POLARPLOTDATAGRAM Plots the datagram as a year polar plot.
%Developed by Michael Ladegaard, Aarhus University, Denmark, 2020.
%
%   [S, PLOTDATAGRAMSURF] = POLARPLOTDATAGRAM(DATAGRAM, METADATA) plots a
%   DATAGRAM with associated METADATA on a polar plot which represents one
%   year. The datagram should thus be one year or less.
%
%   [S, PLOTDATAGRAMSURF] = POLARPLOTDATAGRAM(DATAGRAM, METADATA VARARGIN)
%   allows the specification of extra argumetns. These are:
%%
%
% * 'useKHz' - use kHz on tick labels instead of Hz
% * 'FrequencyLabels' - the frequency labels for tick marks.
% * 'TickColor' - a three element array for the tick mark colour.
% * 'TickLineWidth' - the line width of ticks
% * ''MaxSurfaceSize' - the maximum surface size before inteprolation is
% allowed.

% plot options
tickcol = [0.8 0.8 0.8]; %the tick colour.
ticklinewidth = 2.5; % the tick label width
nfreqticks = 5; % the number of frequency clicks.
labelFc = []; % the frequency labels in Hz
useKhz = false; % true to plot kHz instead of Hz.
maxsurfacesize = 20000; % maxsurface size
uselogfreq= true; % use a logarithmic frequency scale.
tickfontsize = 9;
forcecirclemaxdatagram = false; % true to use the maxmum of the datagram to draw the circle.


%calculate the frequency bins for the datagram.
sR= metadata.sR;
freqoffset = sR/4; 

iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'LogFreq'
            iArg = iArg + 1;
            uselogfreq = varargin{iArg};
        case 'useKhz'
            iArg = iArg + 1;
            useKhz = varargin{iArg};
        case 'FrequencyLabels'
            iArg = iArg + 1;
            labelFc = varargin{iArg};
        case 'TickColor'
            iArg = iArg + 1;
            tickcol = varargin{iArg};
        case 'TickLineWidth'
            iArg = iArg + 1;
            ticklinewidth = varargin{iArg};
        case 'MaxSurfaceSize'
            iArg = iArg + 1;
            maxsurfacesize = varargin{iArg};
        case 'ForceCircleMaxDatagram'
            %a total hack because low log frequencies result in slighly
            %miplaced circle
            iArg = iArg + 1;
            forcecirclemaxdatagram = varargin{iArg};
        case 'FreqOffset'
            iArg = iArg + 1;
            freqoffset = varargin{iArg};
    end
end


if (isempty(metadata.freqbins))
    freqbins  = linspace(0, sR/2, length(datagram(:,1)));
else
    freqbins=metadata.freqbins;
    if isempty(labelFc)
        labelFc = freqbins;
        while (length(labelFc)>10)
            labelFc=labelFc(1:2:end);
        end
        if (labelFc(end)~=freqbins(end))
            labelFc=[labelFc freqbins(end)];
        end
    end
end

%convert frequency to kHz.
if (useKhz)
    freqbins=freqbins/1000.;
end

% auto create the frequency label
if isempty(labelFc)
    if (uselogfreq)
        %equally spaced tick marks on a log scale
        labelFc = [0.01 0.02 0.04 0.08 0.16 0.32 0.64 1]*sR/2;
    else
        labelFc = linspace(0, sR/2, 8)+freqoffset;
    end
    %     labelFc = [20 40 81 162 325 750 1500] ;
elseif (uselogfreq==false)
    labelFc=labelFc+freqoffset;
end

%calculate the interpolated datagram data
if (~isempty(maxsurfacesize))
    [~, ~, datagramplt] = plotdatagram(datagram, metadata, 'plot', false,...
        'MaxSurfaceSize', maxsurfacesize);
else
    [~, ~, datagramplt] = plotdatagram(datagram, metadata, 'plot', false);
end

times = datagramplt.X(1,:);
datagram = datagramplt.datagram;

% put into a time table for easy time calculations.
ttDailyMedian = timetable(datetime(times, 'ConvertFrom', 'datenum')', datagram');
freqBinEdges = [freqbins] ; % Hertz, frequency spacing vector
% Polar plot
doy = day(ttDailyMedian.Properties.RowTimes,'dayofyear') ;
doy = doy - 1 ; % set January 1st to day 0 ; by dividing with 365 in next line, this ensures that data area from Dec 31st and Jan 1st does not overlap
doy = doy / max([365 max(doy)]) ; % scale by 365 days or 366 if it is a leap year and the date Dec 31st is included.
theta = doy*2*pi- pi/2;

% plot the polar plot
if (uselogfreq)
    [THETA,freqFc] = meshgrid(theta,log10(freqBinEdges));
else
    %add sR/4  so that the start of the surface is not the center of the
    %circle. Want a polar plot which is a ring. Ok for log becuase log
    %scale starts at 1 and not 0.
    freqBinEdges=freqBinEdges+freqoffset;
    [THETA,freqFc] = meshgrid(theta,freqBinEdges);
end

[XX,YY] = pol2cart(-THETA,freqFc);
% really important to use edgecolour here because otherwise only surface
% sections of more than one pixel are shown when the plot is view at 0,90.
% Whether this is a feature or bug in MATLAB, who knows.
size(XX)
size(datagram)
s = surf(XX,YY,datagram,'edgecolor','interp');
view(0,90)
hold on
plot3(XX(:,1),YY(:,1),ones(size(YY(:,1)))*max(max(datagram)),'-','Color',tickcol,...
    'LineWidth',ticklinewidth,'HandleVisibility','off')
colormap('Default')

% Centroid frequency tick marks and label
maxradius = 0;
k = 0 ;
Fc_ticklength = 0.02 ;
for j=labelFc
    k = k + 1 ;
    if mod(k,2)==0
        FcCol = tickcol;
    else
        FcCol = tickcol*0.7; % darker
    end
    theta_Fc_scale=1;
    %     theta_Fc_scale = log10(Fc(end))/log10(Fc(j)) ; % scale so that tick marks have equal length ; set scale factor to 1 to disable
    max_i = 8 ;
    for i = 1:max_i
        theta_Fc = linspace(-Fc_ticklength,Fc_ticklength,nfreqticks)*theta_Fc_scale-pi/2*(i*0.5) ;
        %     [THETA2,logFc2] = meshgrid(theta_Fc,ones(size(theta_Fc))*log10(Fc(j)));
        
        if (uselogfreq)
            [XX2,YY2] = pol2cart(-theta_Fc,ones(size(theta_Fc))*log10(j));
        else
            [XX2,YY2] = pol2cart(-theta_Fc,ones(size(theta_Fc))*j);
        end
        
        addfact = 10;
        
        radius = sqrt(XX2(1)^2+YY2(1)^2);
        if maxradius<radius
            maxradius=radius;
        end
        
        hpFc(k) = plot3(XX2,YY2,ones(size(theta_Fc))*max(max(datagram))+addfact,...
            '-','Color',FcCol,'LineWidth',ticklinewidth,'HandleVisibility','off') ;
    end
    
end

% create the tick labels for the months
labelMonth = {'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'} ;

if uselogfreq
    Month_ticklength = 1.5 ; % add scale factor rather than constant to adjust relative to data range
else
    Month_ticklength = 1.06; %linear scale factoris less than the log scale factor
end

rho_Month =  linspace(freqbins(end),freqbins(end)*Month_ticklength,20); %
if (uselogfreq)
    rho_Month=log10(rho_Month);
end

% months text and ticks
for j=1:12  % months
    mNum = month(ttDailyMedian.Properties.RowTimes(1)) + j ; % find month number for the first month after recording start ;
    if mNum > 12
        mNum = mNum - 12 ;
    end
    yNum = datestr(ttDailyMedian.Properties.RowTimes(1),'yy') ; % year(ttDailyMedian.Properties.RowTimes(1)) ;
    if mNum < month(ttDailyMedian.Properties.RowTimes(1)) + 1 % add 1 to get on the right side of recording start time
        yNum = datestr(ttDailyMedian.Properties.RowTimes(1)+years(1),'yy') ; % year(ttDailyMedian.Properties.RowTimes(1))
    end
    theta_Month = zeros(size(rho_Month))-pi/2+(mNum-1)*2*pi/12 ;
    
    % the tick marks for the text
    if (uselogfreq)
        [XX3,YY3] = pol2cart([-theta_Month(1) -theta_Month(1)],[maxradius maxradius*1.07]);
    else
        [XX3,YY3] = pol2cart([-theta_Month(1) -theta_Month(1)],[maxradius maxradius*1.07]);
    end
    
    plot3(XX3,YY3,ones(2)*max(max(datagram)),'-','Color',tickcol,'LineWidth',1.5,'HandleVisibility','off')
    hold on
    
    
    % the positoon of text...
    if (uselogfreq)
        [XX4,YY4] = pol2cart(-theta_Month(1),maxradius*1.15);
    else
        [XX4,YY4] = pol2cart(-theta_Month(1),maxradius*1.15);
    end
    
    htext(mNum) = text(XX4,YY4,max(max(datagram)),join([labelMonth{mNum}," '",yNum],''),'FontSize',tickfontsize) ;
end
for j=[1,7]
    htext(j).HorizontalAlignment = 'center' ;
end
for j=8:12
    htext(j).HorizontalAlignment = 'right' ;
    %     htext(j).Position(1)=htext(j).Extent(1)-htext(j).Extent(4) ;
end

% plot_circle(0,0,max(freqBinEdges), tickcol, ticklinewidth, 2*max(max(datagram)));
if (forcecirclemaxdatagram)
    plot_circle(0,0,max(max(YY(~isinf(YY)))), tickcol, ticklinewidth, 2*max(max(datagram)));
else
    plot_circle(0,0,maxradius, tickcol, ticklinewidth, 2*max(max(datagram)));
end

if (uselogfreq)
    textlabel=labelFc;
else
    % this needs to show the correct frequencies- not the scaled frequencies
    % used for making a nicer looking polar plot.
    textlabel =  labelFc-freqoffset;
end


for i=1:length(textlabel)
    if (textlabel(i)<1000)
        textlabelstr(i)=string(round(textlabel(i), 3, 'significant'));
        unitLabelstr(i) = "Hz";
    else
        textlabelstr(i)=string(num2str(textlabel(i)/1000, '%.1f'));
        unitLabelstr(i) = "kHz";
    end
    
end


hLeg = legend(hpFc, join([textlabelstr',unitLabelstr']));
hLeg.Color = 'none' ;
hLeg.ItemTokenSize = [10 18]; % change the line size in the legend
% position = hLeg.Position;
% position(1)=position(1)*1.2;
% hLeg.Position = position;

c = colorbar('Location', 'northoutside');
c.Label.String = metadata.datagramname;

% hcolbar(tablenum) = colorbar ;
% hcolbar(tablenum).Label.String = 'Third-Octave Level (dB re. 1 µPa)' ;
% hcolbar(tablenum).Label.FontSize = 9 ;
% %     CL = round(prctile(ttDailyMedian{:,:},[1 99],'all')) ; % adjust colour limits to between 1st and 99th percentile
% CL = [60 90] ; % round(prctile(ttDailyMedian{:,:},[1 99],'all')) ; % fixed colour limits
% caxis(CL)
%
% % Title
% htit = text(htext(7).Position(1),htext(7).Position(2)*1.15,htext(7).Position(3),...
%     tableNames{tableNum,1}(strfind(tableNames{tableNum,1},'__')+2:strfind(tableNames{tableNum,1},'.mat')-1),'FontSize',10) ;
% htit.HorizontalAlignment = 'center' ;
% htit.FontWeight = 'bold' ;
% htit.Interpreter = 'none' ;
%
% % % Remove unnecessary axes elements
hax = gca ;
hax.Visible = 'off' ;
%
% toc

% plora surface data
poldatagramsurf.X = XX;
poldatagramsurf.Y = YY;
poldatagramsurf.datagram = datagramplt.datagram;

end

