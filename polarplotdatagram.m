function [s, poldatagramsurf, hLeg] = polarplotdatagram(datagram, metadata, varargin)
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
ticklinewidth = 1.5; % the tick label width
nfreqticks = 5; % the number of frequency clicks.
labelFc = []; % the frequency labels in Hz
useKhz = false; % true to plot kHz instead of Hz.
maxsurfacesize = []; % maxsurface size

iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
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
    end
end

%calculate the frequency bins for the datagram.
sR= metadata.sR;
if (isempty(metadata.freqbins))
    freqbins  = linspace(0, sR/2, length(datagram(:,1)));
else
    freqbins=metadata.freqbins;
    if isempty(labelFc)
        labelFc = freqbins;
        while (length(labelFc)>10)
            labelFc=labelFc(1:2:end);
        end
    end
end

%convert frequency to kHz.
if (useKhz)
    freqbins=freqbins/1000.;
end

% auto create the frequency label
if isempty(labelFc)
    %figure ut exacty the
    labelFc = [0.01 0.02 0.04 0.08 0.16 0.32 0.64 1]*sR/2;
    %     labelFc = [20 40 81 162 325 750 1500] ;
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
[THETA,logFc] = meshgrid(theta,log10(freqBinEdges));
[XX,YY] = pol2cart(THETA,logFc);
s = surf(XX,YY,datagram,'edgecolor','none');
view(0,90)
hold on
plot3(XX(:,1),YY(:,1),ones(size(YY(:,1)))*max(max(datagram)),'-','Color',tickcol,...
    'LineWidth',ticklinewidth,'HandleVisibility','off')
colormap('Default')

% Centroid frequency tick marks and label
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
        [XX2,YY2] = pol2cart(theta_Fc,ones(size(theta_Fc))*log10(j));
        hpFc(k) = plot3(XX2,YY2,ones(size(theta_Fc))*max(max(datagram))+100,...
            '-','Color',FcCol,'LineWidth',ticklinewidth,'HandleVisibility','off') ;
    end
end

% create the tick labels.
labelMonth = {'Jan'; 'Feb'; 'Mar'; 'Apr'; 'May'; 'Jun'; 'Jul'; 'Aug'; 'Sep'; 'Oct'; 'Nov'; 'Dec'} ;
Month_ticklength = 1.5 ; % add scale factor rather than constant to adjust relative to data range
rho_Month = log10( linspace(labelFc(end),labelFc(end)*Month_ticklength,20) ) ; %
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
    %     [THETA3,logFc3] = meshgrid(theta_Fc,ones(size(theta_Fc))*log10(Fc(j)));
    [XX3,YY3] = pol2cart(theta_Month,rho_Month);
    plot3(XX3,YY3,ones(size(rho_Month))*max(max(datagram)),'-','Color',tickcol,'LineWidth',1.5,'HandleVisibility','off')
    hold on
    [XX4,YY4] = pol2cart(theta_Month(1),log10(labelFc(end)*Month_ticklength*1.7));
    htext(mNum) = text(XX4,YY4,max(max(datagram)),join([labelMonth{mNum}," '",yNum],''),'FontSize',9) ;
end
for j=[1,7]
    htext(j).HorizontalAlignment = 'center' ;
end
for j=8:12
    htext(j).HorizontalAlignment = 'right' ;
    %     htext(j).Position(1)=htext(j).Extent(1)-htext(j).Extent(4) ;
end

plot_circle(0,0,max(max(YY(~isinf(YY)))), tickcol, ticklinewidth);
plot_circle(0,0,min(min(YY(~isinf(YY)))), tickcol, ticklinewidth);

if (useKhz)
    unitLabel = 'kHz';
else
    unitLabel = 'Hz';
end
hLeg = legend(hpFc, join([string(round(labelFc, 3, 'significant'))',repmat(unitLabel,length(labelFc), 1)])') ;
hLeg.Color = 'none' ;

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
poldatagramsurf.datagram = datagram;

end

