% binary data folder
binaryFolder='D:\Greenland\Tuttulipaluk2016-17\pamguard\binary\'; 

datatype=3; % the data type 1 for clicks, 2 for whistles. 
sR = 32768; %sample rate in samples per second. 
timebin =1200; % seconds

%% create the datagram
[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype,...
    'TimeBin', timebin);

%% plot the datagram
metadata.sR = sR; % need add sample rate to the metadata
[s, c] = plotdatagram(datagram, metadata, 'UsekHz', false); 
set(gca, 'YScale', 'log')