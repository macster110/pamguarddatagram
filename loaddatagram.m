function [datagram, summarydat, metadata] = loaddatagram(folder, datatype, varargin)
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
%       Note that this assumes an FFT length of 1024 samples. This can be
%       changed by 'FFTLength' argument using VARARGIN.
% * 3 - Noise Band monitor detections.
% 
%  [DATAGRAM, SUMMARYDATA] = LOADDATAGRAM(FOLDER,DATATYPE, VARARGIN) allows
%  additional inpout arguments via VARARGIN. Arguments are:
%
% * 'FFTLength' - the fft length in samples (required for datatype == 2).
%   Default is 1024; 
% * 'TimeBin' - the time bin in seconds for one datagram line. The default is 60
%   seconds 
% * 'FileMask' - a custom file mask if more than one of the same module is
%   used. If this is the case then the unique name of data units for one
%   module is required e.g. 'WhistlesMoans_Moan_Detector_Contours_*'


timebin = 60; %the time bin in seconds
fftLength = 1024; %the fft length
filemaskoverride= []; % overrides the default fuilemask if not empty. 

iArg = 0;
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'FFTLength'
            iArg = iArg + 1;
            fftLength = varargin{iArg};
        case 'TimeBin'
            iArg = iArg + 1;
            timebin = varargin{iArg};
        case 'FileMask'
            iArg = iArg + 1;
            filemaskoverride = varargin{iArg};
    end
end


filerejectmask=[];
% define the correct data function.
switch (datatype)
    case 1
        % Clicks
        getdatagramlin = @(x) clickdatagramline(x);
        filemask='Click_Detector_*.pgdf';
        filerejectmask ='Trigger';
    case 2
        % Whistles and Moans
        % Note: requires an FfftLength
        getdatagramlin = @(x) whistledatagramline(x, fftLength);
        filemask='WhistlesMoans_*.pgdf';
    case 3
        % Noise band monitor
        getdatagramlin = @(x) noisedatagramline(x);
        filemask='Noise_Band_*.pgdf';
end

%custom file mask if the same modules are used 
if (~isempty(filemaskoverride))
   filemask = filemaskoverride; 
end

disp('Counting PAMGuard binary files and loading names...');

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
    metadata.minmaxtime=[];
    return; 
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
        if (~isempty(pgdata))
            dates = [pgdata.date];
            lastfileunit =  max(dates);
        else
            lastfileunit = max(filestarttimes); 
        end
    end
end

% Custom dates go here.
startime = filestarttimes(1);
endtime = lastfileunit;

disp(['Loading data between ' datestr(startime) ' and ' datestr(endtime)]);

% now iterate through the files loading up the data units.
timebinnum = timebin/60/60/24; % the time bin in days arather than seconds
timebins=startime:timebinnum:endtime;

%KEY ASSUMPTION HERE - BINARY FILES ARE IN SEQUENTIAL ORDER
[pgdata, ~] = loadPamguardBinaryFile(d(1).name);
currnetfileN = 1;
%the times in datenum
times = [pgdata.date];

% true untill the first successful datagram line is created. 
newdatagram= true; 

for i=1:length(timebins)-1
    timebinunits=[];
    
    % load from current file
    index = times>timebins(i) & times<timebins(i)+timebinnum;
    timebinunits = [timebinunits pgdata(index)];
    
    %check if a new file needs to be loaded.
    while max(times)<timebins(i)+timebinnum && currnetfileN<length(d)
        
        currnetfileN = currnetfileN +1;
        
        [~, name, ~] = fileparts(d(currnetfileN).name);
        
        disp(['Loading PG file: ' name]);
        
        [pgdata, ~] = loadPamguardBinaryFile(d(currnetfileN).name);
        
        try
            if (~isempty(pgdata))
                times = [pgdata.date];
                
                % load from current file
                index = times>timebins(i) & times<timebins(i)+timebinnum;
                
                %If binary format has, for some reason, changed, then there may
                %be a switch to a slightly different format - this will catch
                %the switch and simply return a timebin with no data.
                timebinunits = [timebinunits pgdata(index)];
            end
        catch e
            disp(e)
        end
    end
    
    disp(['Loading datagram: ' num2str(100*i/length(timebins)) '%' ' No. data units: ' num2str(length(timebinunits))]);
    
    %pre allocate the arrays on the first iteration for speed
    if (newdatagram)
        % get the metadata on the first run so that no recalculated all the
        % time.
        [adatagram, asummarydat, metadata]= getdatagramlin(timebinunits);
        if (~isempty(adatagram))
            % pre allocate the arrays for speed once we know the sizes to use.
            datagram=nan(length(adatagram), length(timebins));
            summarydat=zeros(length(timebins), length(asummarydat));
            newdatagram = false;
        end
    else
        % get the datagram line and the sumamry data.
        [adatagram, asummarydat]= getdatagramlin(timebinunits);
    end
    
    if (~isempty(adatagram))
        % get the datagram line and the sumamry data.
        % if empty should be zeros
        datagram(:,i) = adatagram;
        summarydat(i,:)= asummarydat;
    end
    
end

minmaxtime = [startime, endtime];

%add to meta data. 
metadata.minmaxtime = minmaxtime;
metadata.datatype = datatype;
metadata.freqbins = []; %definet he frequency bins if they are not evenly distributed between 0 and sR

% add any additonal data metadata 
switch (datatype)
    case 1
        % Clicks
    case 2
        % Whistles
    case 3
        % Noise band monitor
        %load up header to get frequency bins. 
        [~, header]= loadPamguardBinaryFile(d(1).name);
        freqbinslow  = header.moduleHeader.loEdges;
        freqbinshigh  = header.moduleHeader.hiEdges;
        for i=1:length(freqbinslow)
            freqbins(i) = freqbinslow(i) + (freqbinshigh(i)-freqbinslow(i))/2;
        end
        metadata.freqbins =  freqbins;
        metadata.freqbinslow = freqbinslow; 
        metadata.freqbinshigh = freqbinshigh; 
end

%add time bins to summary data
summarydat = [(timebins(1:end-1)+timebinnum)'; timebinnum]; %center of time bins

% end

