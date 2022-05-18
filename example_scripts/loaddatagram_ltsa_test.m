%% load an LTSA and plot
pamguardbinaryfolder ='/Volumes/GoogleDrive-108005893101854397430/My Drive/Aarhus_research/PAMGuard_bats_2020/detection_comparison/deploynment_5_audiomoth/Skovsoe_continuous_audiomoth/Binary5A/';

%path to pamguard binary storage folder
% pamguardbinaryfolder = '/Volumes/GoogleDrive-108005893101854397430/My Drive/SMRU_research/Gill nets 2016-20/SoundTraps/st_data/806109211/Binary';

detindex = 4; %LTSA
hsens = -175; % dB re 1V/uPa hydrophone sensitivity
gain =0; % additonal gain
vp2p = 2; %V Daq card peak to peak voltage range
sR = 384000; % sample rate.


% [ltsa_data, fileinfo] = loadPamguardBinaryFile('/Users/au671271/Google Drive/Aarhus_research/PAMGuard_bats_2020/trigger_cont_comparison/deploynment_5_audiomoth/Skovsoe_continuous_audiomoth/Binary5A/20200817/LTSA_Long_Term_Spectral_Average_LTSA_20200817_011832.pgdf'); 
% [datagramline, summarydata, metadata] = ltsadatagramline(ltsa_data, fileinfo); 

% calculate a datagram
[datagram, summarydat, metadata] = loaddatagram(pamguardbinaryfolder, detindex, ...
    'TimeBin', 10, 'Gain', gain, 'HSens', hsens, 'vp2p', 2);

% plot the datagram
metadata.sR = sR;
[s, c] = plotdatagram(datagram, metadata);
datetick('KeepLimits', 'x')
set(gca, 'FontSize', 14)