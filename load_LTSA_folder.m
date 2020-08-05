function [ltsa_spectrum, ltsa_time, interval, ltsa_spectrumdB] = ...
    load_LTSA_folder(folder, channel, day_num_start, day_num_end, ...
    plotLTSA, hsens, vp2p, gain, clims, concatmins)
%%LOAD_LTSA_FOLDER load a folder of LTSA files and create an LTSA spectrum.
% [LTSA_SPECTRUM, LTSA_TIME, INTERVAL, LTSA_SPECTRUMDB]
% =LOAD_LTSA_FOLDER(FOLDER, CHANNEL) loads a and plots LTSA data from a
% FOLDER containing binary files for a specified CHANNEL (not a channel
% bitmap). The function returns the LTSA_SPECTRUM which is the raw LTSA
% spectrum from binary files in a 2D array with each column representing
% one LTSA time slice. LTSA_TIME is an array corresponding to LTSA_SPECTRUM
% with the date-time of each time slice as a MATLAB datenum. INTERVAL is
% the LTSA interval which is specified in PAMGuard settings.
% LTSA_SPECTRUMDB is the true frequency root hertz spectrum based on
% default recorder settings.hsens=-201 dB re 1V/1uPa gain=20 dB; vp2p=2V;
%
% [LTSA_SPECTRUM, LTSA_TIME, INTERVAL, LTSA_SPECTRUMDB]
% =LOAD_LTSA_FOLDER(FOLDER, CHANNEL, DAY_NUM_START, DAY_NUM_END) loads an
% plots an LTSA between times DAY_NUM_START and DAY_NUM_END.
%
% [LTSA_SPECTRUM, LTSA_TIME, INTERVAL, LTSA_SPECTRUMDB]
% =LOAD_LTSA_FOLDER(FOLDER, CHANNEL, DAY_NUM_START, DAY_NUM_END, PLOT)
% allows users to specify whether the LTSA is plotted.
%
% [LTSA_SPECTRUM, LTSA_TIME, INTERVAL, LTSA_SPECTRUMDB]
% =LOAD_LTSA_FOLDER(FOLDER, CHANNEL, DAY_NUM_START, DAY_NUM_END, PLOT, HSENS
%   VP2P, GAIN) allows users to specifiy the recorder settings. HSENS is
%   theh hydrophone calibration in dB re 1V/1uPa. The GAIN is in dB and the
%   VP2P is the total voltage range of the DAQ system in volts.
%
% [LTSA_SPECTRUM, LTSA_TIME, INTERVAL, LTSA_SPECTRUMDB]
% =LOAD_LTSA_FOLDER(FOLDER, CHANNEL, DAY_NUM_START, DAY_NUM_END, PLOT, HSENS
%   VP2P, GAIN, CLIMITS) CLIMITS allows user to specify colour limits in dB

% day_start='14-07-2013 08:00:00';
% day_end='14-07-2013 17:30:00';
% folder='E:\Google Drive\SMRU_research\Corryvreckan 2013\LTSA';
% channel=4;
% gain=49;
% hsens=-197.7;
% vp2p=4;
% plotLTSA=true;
% climits=[45 90]

% folder='C:\Users\jamie\Google Drive\SMRU_research\Silurian 2014\Vertical_Array_10\Binary\';
% folder='C:\Users\jamie\Google Drive\SMRU_research\Corryvreckan 2013\LTSA';
% sR=500000; %%TODO- no need to hardwire these values.
% channel=5;
% day_start='14-07-2013 08:00:00';
% day_end='14-07-2013 17:30:00';
% plotLTSA=true;

%% times to use
%% The great race
% day_start='17-07-2013 00:00:00';
% day_end='17-07-2013 19:30:00';

% day_start='10-07-2013 14:00:00';
% day_end='10-07-2013 14:30:00';

% day_start='27-08-2014 00:00:00';
% day_end='27-08-2014 23:59:00';
% if nargin<2;
%  channel=0;
%  day_start='27-08-1970 00:00:00';
%  day_end='27-08-3000 23:59:00';
%  plotLTSA=false;
% end
% if nargin<4;
%  day_start='27-08-1970 00:00:00';
%  day_end='27-08-3000 23:59:00';
%  plotLTSA=false;
% end
% if nargin<5;
%     plotLTSA=false;
% end

% day_start='30-05-2016 00:00:00';
% day_end='30-05-2016 23:59:59';
% channel=0;
% plotLTSA=true;
% %LTSA folder
% folder='F:\Analysis\binary';

if (nargin<=2)
    day_num_start=0;
    day_num_end=realmax-100;
    clims=[45 80];
end

if (nargin<=4)
    plotLTSA=true;
    hsens=-201;
    gain=20;
    vp2p=2;
    clims=[45 80];
end

if (nargin<=5)
    hsens=-201;
    gain=20;
    vp2p=2;
    clims=[45 80];
end

if (nargin<=6)
    clims=[45 80];
    hsens=-201;
    gain=20;
    vp2p=2;
end

if (nargin<=8)
    clims=[45 80];
end

if (nargin<=9)
    concatmins = true; 
end

binary_files=findBinaryFiles(folder);

n=1;
for i=1:length(binary_files)-1
    [pathstr,name,ext] = fileparts(binary_files{i}) ;
    if contains(name, 'LTSA')
        
        [ltsa_data, moduleheader]=loadPamguardBinaryFile(binary_files{i});
        if (isstruct(moduleheader))
            interval=moduleheader.moduleHeader.intervalSeconds;
        end
        for j=1:length(ltsa_data)
            ltsa_channels=getChannels(ltsa_data(j).channelMap);
            for k=1:length(ltsa_channels)
                if (ltsa_channels(k)==channel)
                    if (mod(i,10)==0)
                        disp(['LTSA file found ' num2str(i)])
                    end
                    %add ltsa data to array.
                    if (~isempty(ltsa_data(j).data))
                        ltsa_spectrum(:,n)=ltsa_data(j).data(:,k);
                        ltsa_time(n)=ltsa_data(j).date;
                        ltsa_nFFT(n)=ltsa_data(j).nFFT;
                        n=n+1;
                    else
                        disp(['Warning LTSA bin was empty: ' datestr(ltsa_data(j).date)])   
                    end
                end
            end
        end
    end
end

sR=moduleheader.moduleHeader.fftHop/moduleheader.moduleHeader.intervalSeconds;
fftllen=moduleheader.moduleHeader.fftLength;

for i=1:n-1
    disp(['Calculating ' num2str(i)])
    ltsa_spectrumdB(:,i)=fftamplitude_2dB(ltsa_spectrum(:,i).^2,sR, fftllen, true,  vp2p, hsens, gain);
end

% day_num_start=datenum(day_start,'dd-mm-yyyy HH:MM:SS');
% day_num_end=datenum(day_end,'dd-mm-yyyy HH:MM:SS');
index_OK=find(ltsa_time> day_num_start & ltsa_time<=day_num_end);
ltsa_time=ltsa_time(index_OK);
ltsa_spectrum=ltsa_spectrum(:,index_OK); %%grid of values.
ltsa_spectrumdB=ltsa_spectrumdB(:,index_OK); %%grid of values.

if (isempty(ltsa_spectrumdB))
    disp('It appears there is no data within time period?');
    return;
end

fftsize=length(ltsa_spectrumdB(:,1));

interval=interval/60; % make into minutes
if (plotLTSA)
    
    freqbin=sR/2/fftsize;
    %% need to make a meshgrid
    
    if (concatmins)
        [Xinterp,Yinterp] = meshgrid((1:length(ltsa_time))*(interval),(1:fftsize)*freqbin);
        xlims = [0 length(ltsa_time)*(interval)];
    else
        [Xinterp,Yinterp] = meshgrid(ltsa_time,(1:fftsize)*freqbin);
        xlims = [day_num_start day_num_end];
    end
    
    %%to use datetick
    %[Xinterp,Yinterp] = meshgrid(ltsa_time,(1:fftsize)*freqbin);
    
    %%now plot a surface
    surf(Xinterp, Yinterp, ltsa_spectrumdB,'EdgeColor','none')
    xlim(xlims);
    
    ylim([0 sR/2]);
    
    colormap jet;
    caxis(clims)
    
    xlabel('Time (minutes)')
    %     datetick
    ylabel('Frequency (kHz)');
    view(0,90) %%set view angle
    %     axis([1 length(ltsa_spectrum(1,:)) 1 length(ltsa_spectrum(:,1))])
    %     ax = gca;
    %         ax.YTickLabel = {'25','50','75','100','125','150','175','200','225','250'};
    c=colorbar('northoutside');
    c.Label.FontSize = 12;
    c.Label.Interpreter='tex';
    c.Label.String = 'dB re 1\muPa / \surdHz';
    
end
end


