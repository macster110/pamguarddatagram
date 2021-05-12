% binary data folder
% binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20191114_Cornwall_AK627_H3\67170312\Binary\';
binaryFolder='D:\Greenland\Tuttulipaluk2016-17\pamguard\binary\20160825\'; 

datatype=2; % the data type 1 for clicks, 2 for whistles. 
sR = 2000; %sample rate in samples per second. 
timebin =600; % seconds
fftLength = 512; % the FFT leangth used in PAMGuard if using whistles 

%% create the datagram
[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype,...
    'TimeBin', timebin, 'FileMask', 'WhistlesMoans_Moan_Detector_Contours_*', 'FFTLength', fftLength);

%% plot the datagram
metadata.sR = sR; % need add sample rate to the metadata
[s, c] = plotdatagram(datagram, metadata, 'UsekHz', true); 

