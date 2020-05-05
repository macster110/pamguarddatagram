function [datagram, summarydat, minmaxtime] = loaddatagram(folder, datatype, timebin, varargin)
%LOADDATAGRAM Creates a datagram from PAMGuard binary data
%   [DATAGRAM, SUMMARYDATA] = LOADDATAGRAM(FOLDER,DATATYPE) generates a
%   datagram from a a FOLDER of PAMGaurd binary files along with
%   SUMMARYDATA metrics for a specified set of time bins. A DATAGRAM is a
%   FREQUENCY/TIME surface anologous to a psectorgram but using frequency
%   metrics from detectiond ata rathaer than raw data. SUMMARDATA is a
%   custom set of metrics where each row represents one DATAGRAM line. The
%   data is entirely dependent on DATATYPE. See individual **datagramline
%   functions for what is in SUMMARYDATA.
%%
% * 1 - Click detections from Click Detector module.
% * 2 - Whistle and moan detections from Whistle and Moan Detector module.
% * 3 - Noise Band monitor detections. 

filerejectmask=[]; 
% define the correct data function.
switch (datatype)
    case 1
        %Clicks
        getdatagramlin = @(x) clickdatagramline(x);
        filemask='Click_Detector_*.pgdf';
        filerejectmask ='Trigger'; 
    case 2
        getdatagramlin = @(x) clickdatagramline(x);
        filemask='WhistleMoans_*.pgdf';
end

%can have a csutom file mask if necessary.
%%TODO

% first open all the file headers
d = dirsub(folder, filemask);
%remove unwanted files
if ~isempty(filerejectmask)
    indexOK = [];
    for i=1:length(d)
        if ~contains(d(i).name, filerejectmask)
            indexOK=[indexOK i]; 
        end
    end
    d=d(indexOK); 
end

if (isempty(d))
   disp('THERE ARE NO BINARY FILES AT THIS LOCATION? CHECK FILE PATH...');
   datagram=[]; 
   summarydat=[]; 
   minmaxtime=[]; 
end


% figure out the fiel start times
filestarttimes = zeros(length(d), 1);
for i = 1:numel(d)
    %      fprintf('Loading %s\n', d(i).name);
    
    fid = fopen(d(i).name, 'r', 'ieee-be.l64');
    header = readFileHeader(fid, false);
    fclose(fid);
    
    filestarttimes(i)=header.dataDate;
    
    fprintf('Checking file %d of %d at %s\n', i, numel(d), datestr(filestarttimes(i)));
    
    if (i==numel(d))
        %load the last file to check the final date
        [pgdata, ~] = loadPamguardBinaryFile(d(i).name);
        dates = [pgdata.date];
        lastfileunit =  max(dates);
    end
end

% Custom dates go here.
startime = filestarttimes(1);
endtime = lastfileunit;

disp(['Loading data between ' datestr(startime) ' and ' datestr(endtime)]);

% now iterate through the files loading up the data units.
timebinnum = timebin/60/60/24; % the time bin in days arather than seconds
timebins=startime:timebinnum:endtime;

%KEY ASSUMPTION HERE - BINARY FILESARE IN SEQUENTIAL ORDER
[pgdata, ~] = loadPamguardBinaryFile(d(1).name);
currnetfileN = 1;
%the times in datenum
times = [pgdata.date];

for i=1:length(timebins)-1
    timebinunits=[];
    
    % load from current file
    index = times>timebins(i) & times<timebins(i)+timebinnum;
    timebinunits = [timebinunits pgdata(index)];
    
    %check if a new file needs to be loaded.
    while max(times)<timebins(i)+timebinnum
        
        currnetfileN = currnetfileN +1;
        
        disp(['Loading PG file: ' d(currnetfileN).name]);
        [pgdata, ~] = loadPamguardBinaryFile(d(currnetfileN).name);
        
        times = [pgdata.date];
        
        % load from current file
        index = times>timebins(i) & times<timebins(i)+timebinnum;
        
        try
            %If binary format has, for some reason, changed, then there may
            %be a switch to a slightly different format - this will catch
            %the switch and simply return a timebin with no data.
            timebinunits = [timebinunits pgdata(index)];
        catch e
            disp(e)
        end
    end
    
    disp(['Loading datagram: ' num2str(100*i/length(timebins)) '%' ' No. data units: ' num2str(length(timebinunits))]);
    
    %pre allocate the arrays
    if (i==1)
        % get the datagram line and the sumamry data.
        [adatagram, asummarydat]= getdatagramlin(timebinunits);
        % pre allocate the arrays for speed once we know the sizes to use. 
        datagram=nan(length(adatagram), length(timebins)); 
        summarydat=zeros(length(timebins), length(asummarydat)); 
    else
        % get the datagram line and the sumamry data.
        [datagram(:,i), summarydat(i,:)]= getdatagramlin(timebinunits);
    end
end

minmaxtime = [startime, endtime];

% end

