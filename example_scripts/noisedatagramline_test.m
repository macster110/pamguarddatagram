
file = 'E:\Google Drive\Aarhus_research\Greenland_PAM_2020\ExampleData1\PAM_Binary\20200317\Noise_Band_Noise_Band_Monitor_Noise_Band_Monitor_20200317_104241.pgdf';

[noisedata, moduleheader]= loadPamguardBinaryFile(file); 

[datagramline, summarydata] = noisedatagramline(noisedata); 

plot(datagramline); 