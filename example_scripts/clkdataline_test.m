 %tets the click dataline
file = "C:\Users\Jamie Macaulay\Desktop\Vertical_array_soundtrap\PLA1-Binary\20230520\Click_Detector_Click_Detector_Clicks_20230520_192338.pgdf";
[clicks, moduleinfo] = loadPamguardBinaryFile(file); 

[datagramline,summarydata, metadata] = clickdatagramline(clicks); 