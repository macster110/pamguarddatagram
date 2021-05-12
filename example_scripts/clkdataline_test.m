 %tets the click dataline
file = 'F:\Middlefart_PAM\BACKUP_20200220\Middelfart\Binary_WithUID\20180315\Click_Detector_HF_Click_Detector_Clicks_20180315_080000.pgdf'; 

clicks = loadPamguardBinaryFile(file); 

[datagramline,summarydata, metadata] = clickdatagramline(clicks); 