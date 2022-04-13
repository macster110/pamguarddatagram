 %tets the click dataline
file = '/Volumes/GoogleDrive-108005893101854397430/My Drive/SMRU_research/Gill nets 2016-20/SoundTraps/st_data/67411977/Binary/20170705/Click_Detector_Click_Detector_Clicks_20170705_190008.pgdf';
[clicks, moduleinfo] = loadPamguardBinaryFile(file); 

[datagramline,summarydata, metadata] = clickdatagramline(clicks); 