% binary data folder
% binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20191114_Cornwall_AK627_H3\67170312\Binary\';
binaryFolder='D:\Greenland\Tuttulipaluk2016-17\pamguard\binary\'; 

datatype=2; % the data type 1 for clicks, 2 for whistles. 
sR = 576000; %sample rate in samples per second. 
timebin =600; % seconds

fftLength = 1024; 

%% create the datagram

[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype,...
    'TimeBin', timebin, 'FileMask', 'WhistlesMoans_Moan_Detector_Contours_*' );

%% plot the datagram
metadata.sR = sR; % need add sample rate to the metadata
[s] = plotdatagram(datagram, metadata, 'UsekHz', true); 

