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
% * 4 - Long term spectral average data form the LTSA module.
% * 5 - Clip data from the clip module.
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
% * 'DetectionFilter' - a custom filter for the datagram. This is a
%   function handle of the form INDEX = DETFILTER(DATAUNITS) where index is
%   the DATAUNITS in a a datgram bin to keep.
% * 'Gain' - the gain of the amplifier used in dB
% * 'vp2p' - the peak to peak voltage in volts of the DAQ system
% * 'HSens' - the sensitivity of the hydrophone in dB re 1V/uPa
% * 'CustomString' - adds a custom string to the end of the progress output



timebin = 60; %the time bin in seconds
fftLength = 1024; %the fft length
sR = 96000; % the sample rate in samples per second.
filemaskoverride= []; % overrides the default fuilemask if not empty.
savefile=[]; %saves data contiously to a .mat file.
detfilter=[]; % the detection filter function.
timelims = [-inf, inf];  % no time lims;
iArg = 0;
customstring =''; % adds some custom output to the progress indicator.
hsens=-175; %dB re 1V/uPa - default system sensitivity for a SoundTrap;
gain = 0; %dB - default for a SoundTrap
vp2p = 2; %V - default for SoundtRAP
while iArg < numel(varargin)
    iArg = iArg + 1;
    switch(varargin{iArg})
        case 'FFTLength'
            iArg = iArg + 1;
            fftLength = varargin{iArg};
        case 'SampleRate'
            iArg = iArg + 1;
            sR = varargin{iArg};
        case 'TimeBin'
            iArg = iArg + 1;
            timebin = varargin{iArg};
        case 'FileMask'
            iArg = iArg + 1;
            filemaskoverride = varargin{iArg};
        case 'SaveFile'
            iArg = iArg + 1;
            savefile = varargin{iArg};
        case 'DetectionFilter'
            iArg = iArg + 1;
            detfilter = varargin{iArg};
        case 'TimeLims'
            iArg = iArg + 1; 
            timelims = varargin{iArg};
        case 'CustomString'
            iArg = iArg + 1;
            customstring = varargin{iArg};
        case 'Gain'
            iArg = iArg + 1;
            gain = varargin{iArg};
        case 'vp2p'
            iArg = iArg + 1;
            vp2p = varargin{iArg};
        case 'HSens'
            iArg = iArg + 1;
            hsens = varargin{iArg};
    end
end


filetypestring = '';
filerejectmask=[];
% define the correct data function.
switch (datatype)
    case 1
        % Clicks
        getdatagramlin = @(x, y) clickdatagramline(x, y);
        filemask='Click_Detector_*.pgdf';
        filerejectmask ='Trigger';
        filetypestring = 'click';
    case 2
        % Whistles and Moans
        % Note: requires an FfftLength
        getdatagramlin = @(x, y) whistledatagramline(x, y, fftLength, sR);
        filemask='WhistlesMoans_*.pgdf';
        filetypestring = 'whistle and moan';
    case 3
        % Noise band monitor
        getdatagramlin = @(x, y) noisedatagramline(x, y);
        filemask='Noise_Band_*.pgdf';
        filetypestring = 'noise band';
    case 4
        % LTSA
        getdatagramlin = @(x, y) ltsadatagramline(x, y, hsens, gain, vp2p);
        filemask='LTSA_*.pgdf';
        filetypestring = 'LTSA';
    case 5
        % Clips
        getdatagramlin = @(x, y) clipdatagramline(x, y);
        filemask='Clip_Generator_*.pgdf';
        filetypestring = 'clip';
end

%custom file mask if the same modules are used
if (~isempty(filemaskoverride))
    filemask = filemaskoverride;
end

disp(['Counting PAMGuard binary files and loading names...' customstring]);

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
    disp(['THERE ARE NO BINARY FILES AT THIS LOCATION? CHECK FILE PATH...' folder]);
    datagram=[];
    summarydat=[];
    metadata.minmaxtime=[];
    return;
end


% figure out the file start times
filestarttimes = zeros(length(d), 1);
% fileendtimes = zeros(length(d), 1);

for i = 1:numel(d)
    %      fprintf('Loading %s\n', d(i).name);
    try
        fid = fopen(d(i).name, 'r', 'ieee-be.l64');
        header = readFileHeader(fid, false);

        %the footer does not contain relaible file end times - maybe in
        %later version of PG but not earlier ones...
        %         footer = readFileFooter(fid);
        fclose(fid);

        filestarttimes(i)=header.dataDate;

        fprintf('Checking %s file %d of %d at %s %s\n', filetypestring, i, numel(d), datestr(filestarttimes(i)), customstring);

    catch e
        disp(e)
    end
end


fileendtimes = [filestarttimes(2:end) ; (filestarttimes(end) + 1)]; % make up the last end time by adding a day....meh

%filter by time limits
% datestr(filestarttimes)
% datestr(fileendtimes)
index = fileendtimes<=timelims(1) | filestarttimes>timelims(2) ...
    | filestarttimes<datenum('1970-01-01 00:00:00', 'yyyy-mm-dd HH:MM:SS');

filestarttimes(index)=[];
fileendtimes(index)=[];
d(index)=[];

% datestr(filestarttimes)

% we have a slight issue here.The file end times are the file start times
% and this it is assumed that files are concurrent. This is OK for most
% file but, if the first file is way before the other files then you get a
% huge datagram with loads of space - this only occurs when the time limits
% straddle a large break in files..So we need to check the first file and
% the only way to do that is open it.

disp(['Check whether first file is needed: ' d(1).name])
%open the first file to check whether it is actually needed
[pgdata, fileinfo] = loadPamguardBinaryFile(d(1).name);

if (pgdata(end).date<timelims(1))
    filestarttimes = filestarttimes(2:end);
    fileendtimes = fileendtimes(2:end);
    d = d(2:end);
end

disp(['Check last data unit in last file: ' d(end).name])
%load te last file to check the final date
[pgdata, ~] = loadPamguardBinaryFile(d(end).name);
if (~isempty(pgdata))
    dates = [pgdata.date];
    lastfileunit =  max(dates);
else
    lastfileunit = max(fileendtimes);
end


datestr(lastfileunit)

if (isinf(timelims(1)))
    % No dates set - use binary files as start and end
    startime = filestarttimes(1);
    if (~isempty(lastfileunit))
        endtime = lastfileunit;
    else
        endtime = fileendtimes(end);
    end
else 
    startime = timelims(1);
    endtime = timelims(2);
end
%     %in case the last file is corrupt
%     endtime = filestarttimes(end);
% end

disp(['Loading ' filetypestring ' data between ' datestr(startime) ' and ' datestr(endtime) '  ' customstring]);

% now iterate through the files loading up the data units.
timebinnum = timebin/60/60/24; % the time bin in days arather than seconds
timebins=startime:timebinnum:endtime;

%KEY ASSUMPTION HERE - BINARY FILES ARE IN SEQUENTIAL ORDER

%find first non empty file
pgdata=[];
currnetfileN=0; %needs to be zero otherwise first file is missed...
while isempty(pgdata)
    currnetfileN = currnetfileN+1;
    disp(['Loading PG file: ' d(currnetfileN).name '  ' num2str(currnetfileN)]);
    [pgdata, fileinfo] = loadPamguardBinaryFile(d(currnetfileN).name);
end

try
    %the times in datenum
    times = [pgdata.date];
catch e
    disp(e)
    return
end

% true until the first successful datagram line is created.
newdatagram= true;
summarydat=[];
datagram=[];

for i=1:length(timebins)-1
    timebinunits=[];

    % load from current file
    index = times>timebins(i) & times<timebins(i)+timebinnum;
    timebinunits = [timebinunits pgdata(index)];

    %check if a new file needs to be loaded.
    while max(times)<timebins(i)+timebinnum && currnetfileN<length(d)

        currnetfileN = currnetfileN +1;

        [~, name, ~] = fileparts(d(currnetfileN).name);

        disp(['Loading PG file: ' name '  ' num2str(currnetfileN)]);


        try

            [pgdata, fileinfo] = loadPamguardBinaryFile(d(currnetfileN).name);

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

    if (mod(i,10)==0)
        disp(['Loading datagram: ' filetypestring ' ' num2str(100*i/length(timebins)) ...
            '%' ' No. data units: ' num2str(length(timebinunits)) '  '  customstring]);
    end

    if (~isempty(timebinunits) && ~isempty(detfilter))

        % further filter the data if ther eis a function
        index = detfilter(timebinunits);

        if (isempty(index))
            timebinunits=[];
        else
            timebinunits = timebinunits(index);
        end
    end

    %pre allocate the arrays on the first iteration for speed
    if (newdatagram)
        % get the metadata on the first run so that no recalculated all the
        % time.
        [adatagram, asummarydat, metadata]= getdatagramlin(timebinunits, fileinfo);
        if (~isempty(adatagram))
            % pre allocate the arrays for speed once we know the sizes to use.
            datagram=nan(length(adatagram), length(timebins)-1);
            summarydat=zeros(length(timebins)-1, length(asummarydat));
            newdatagram = false;
        end
    else
        % get the datagram line and the sumamry data.
        [adatagram, asummarydat]= getdatagramlin(timebinunits, fileinfo);
    end

    %     asummarydat
    if (~isempty(adatagram))
        % get the datagram line and the summary data.
        % if empty should be zeros.
        %Try to pre empt mistakes
        if (iscolumn(adatagram))
            datagram(:,i) = adatagram(:,1);
        else
            % in case someone makes a mistake in their dataline function
            datagram(1:length(adatagram(1,:)),i) = adatagram(1,:);
        end
        summarydat(i,1:length(asummarydat(1,:)))= asummarydat(1,:);
    end

    if (mod(i,50)==0 && ~isempty(savefile))
        %save the file
        save(savefile,'datagram','summarydat')
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
times=(timebins(1:end-1)+timebinnum)';

summarydat = [times summarydat]; %center of time bins

%save the file with metadata
if (~isempty(savefile))
    save(savefile,'datagram','summarydat', 'metadata')
end

end

