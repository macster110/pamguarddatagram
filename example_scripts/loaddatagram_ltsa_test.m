%% load an LTSA and plot
pamguardbinaryfolder ='/Users/au671271/Google Drive/Aarhus_research/PAMGuard_bats_2020/trigger_cont_comparison/deploynment_5_audiomoth/Skovsoe_continuous_audiomoth/Binary5A/20200817';

detindex = 4; %LTSA

[ltsa_data, fileinfo] = loadPamguardBinaryFile('/Users/au671271/Google Drive/Aarhus_research/PAMGuard_bats_2020/trigger_cont_comparison/deploynment_5_audiomoth/Skovsoe_continuous_audiomoth/Binary5A/20200817/LTSA_Long_Term_Spectral_Average_LTSA_20200817_011832.pgdf'); 
[datagramline, summarydata, metadata] = ltsadatagramline(ltsa_data, fileinfo); 

% calculate a datagram
[datagram, summarydat, metadata] = loaddatagram(pamguardbinaryfolder, detindex, 'TimeBin', 10);

% plot the datagram
[s, c] = plotdatagram(20*log10(datagram), metadata);