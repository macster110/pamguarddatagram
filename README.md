# pamguardDatagram

Generate datagrams from data processed in [PAMGuard](www.PAMGuard.org)

## Introduction 
PAMGuard is an open source acoustic analysis tool designed to detect, classify and localise the voclaisations of soniferious marine mammals (baleen whales, sperm whales, dolphins, river dolphins, beaked whales, porpoise) and some terrestrial species such as bats. PAMGuard can analyse years of acoustic data and store relevent detections, classifcations and metrics such as noise/long term spectral averages etc. in a highly compressed "binary file" format. This means that terrabytes of acoustic data can be reduced by 99.9% in size whilst retaining sufficient information to allow manual analysts to inspect data and re-run classification algorithms etc. 

<center><img src="resources/pgdatagram_example.png" width="1024"></center>
An example of a years worth of data analysed using PAMGuard tonal and click detectors alongside a long term spectral average. 

## pamguardDatagram
PAMGuard binary files can be loaded into PAMGuard where a user can access the multide of interactive displays or accessed through [R] (https://github.com/TaikiSan21/PamBinaries) and [MATLAB](https://sourceforge.net/projects/pamguard/files/Matlab/) libraries for more bespoke analysis. pamguardDatagram is a set functions which recreates the PAMGuard datagram showing a summary of months or even years of acosutic data. 

## Usage
This requires the PAMGuard [MATLAB library](https://sourceforge.net/projects/pamguard/files/Matlab/) which should be added to your MATLAB path. Building a datagram also requires acoustic data to have been analysed in PAMGuard and saved to PAMGuard binary files (see pamguard help -> Binary File Module). 

There are two inputs to the datagram folder; a path to the binary file folder and a ```datatype```. ```dataype``` is an integer number and indictaes which data stream you wish to analyse. Current enabled ```datatypes``` are:

- 1 -> Click detections from the Click Detector Module.
- 2 -> Whistle and Moan detections from the Whistle and Moan detector Module. 
- 3 -> Noise Band monitor.

## Example code 

```Matlab
% path to a binary file folder
binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20191114_Cornwall_AK627_H3\67170312\Binary\20191115\';

datatype=1; % data type 1 is clicks 
sR = 576000; %sample rate in samples per second
timebin =60; % seconds

%% load the datagram.
[datagram, summarydata, metadata] = loaddatagram(binaryFolder,datatype, timebin);

%% plot the datagram 
[s] = plotdatagram(datagram, metadata, 'UseKHz', true); 
```
