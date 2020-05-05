# pamguardDatagram

Generate datagrams from data processed in PAMGuard (www.PAMGuard.org)

## Introduction 
PAMGuard is an open source acoustic analysis tool designed to detect, classify and localise the voclaisations of soniferious marine 
(baleen whales, sperm whales, dolphins, river dolphins, beaked whales, porpoise) and some terrestrial species such as bats. PAMGuard can analyse years of acosutic data
and store relevent detections, classiifcations and metrics such as noise/long term spectral averages etc. in a highly compressed "binary file" format. This means 
that terrabytes of acoustic data can be reduced by 99.9% in size whilst retaining sufficient information to allow manaula analysts to inspect data 
and re-run classification algorithms etc. 


## pamguardDatagram
PAMGuard binary files can be loaded into PAMGuard or accessed through R () and MATLAB (). 
