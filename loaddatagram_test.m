
binaryFolder = 'E:\Google Drive\SMRU_research\Gill nets 2016-20\SoundTrap_4c\20191114_Cornwall_AK627_H3\67170312\Binary\20191115\';

datatype=1;
sR = 576000;
timebin =60; % seconds

%% load the datagram.
[datagram, summarydata, minmaxtime] = loaddatagram(binaryFolder,datatype, timebin);

%% Plot the datagram
usekHz= true;

[X, Y] = meshgrid(...
    linspace(minmaxtime(1), minmaxtime(2), length(datagram(1,:))),...
    linspace(0, sR/2, length(datagram(:,1))));

if usekHz
    Y=Y./1000;
end

s = surf(X, Y, 20*log10(datagram), 'EdgeColor', 'none');
ylabel('Frequency (kHz)')
xlabel('Time')
datetick x
xlim([minmaxtime(1), minmaxtime(2)])

freqlimits=[0, sR/2];
if usekHz
    freqlimits=freqlimits/1000.;
end
ylim(freqlimits); 


colormap Jet
colorbar
view([0,90])


