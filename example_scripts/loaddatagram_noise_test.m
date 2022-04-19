% binary data folder
binaryFolder='D:\Greenland\Tuttulipaluk2016-17\pamguard\binary\'; 

datatype = 3; % the data type 1 for clicks, 2 for whistles. 
sR = 32768; %sample rate in samples per second. 
timebin =1200; % seconds

%Optionally add DAQ info to get true spectral levels. 
gain = 0; 
hsens = -175; % default for a SoundTrap
vp2p = 2; %default for SoundTraps

%% create the datagram
[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype,...
    'TimeBin', timebin, 'Gain', gain, 'HSens', hsens, 'vp2p', vp2p);

%% plot the datagram
metadata.sR = sR; % need add sample rate to the metadata for plotting
[s, c] = plotdatagram(datagram, metadata, 'UsekHz', false); 
set(gca, 'YScale', 'log')