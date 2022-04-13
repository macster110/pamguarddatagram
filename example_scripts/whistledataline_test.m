clear

file = '/Volumes/GoogleDrive-108005893101854397430/My Drive/SMRU_research/Gill nets 2016-20/SoundTrap_4c/20191114_Cornwall_AK627_H3/67170312/Binary/20191115/WhistlesMoans_Whistle_and_Moan_Detector_Contours_20191115_183157.pgdf';


[tones, wmheader]= loadPamguardBinaryFile(file); 

fftLength = 1024; 
sR = 96000; 
[dataline, line, metadata] = whistledatagramline(tones, fftLength, sR); 

plot(dataline)



