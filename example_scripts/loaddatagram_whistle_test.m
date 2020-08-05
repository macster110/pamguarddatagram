% binary data folder
binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20191114_Cornwall_AK627_H3\67170312\Binary\';

% binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20190711_Cornwall_AK615_H1\134250533\Binary\'; 
% binaryFolder='D:\Greenland\Tuttulipaluk2016-17\pamguard\binary\'; 

datatype=2; % the data type 1 for clicks, 2 for whistles. 
sR = 48000; %sample rate in samples per second. 
timebin =60; % seconds

fftLength = 1024; %the fft length used in PG 

%% create the datagram
[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype,...
    'TimeBin', timebin, 'FFTLength', fftLength);

%% plot the datagram
metadata.sR = sR; % need add sample rate to the metadata
[s, c] = plotdatagram(datagram, metadata, 'UsekHz', true); 

