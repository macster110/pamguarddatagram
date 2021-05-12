function [ttdatagram, ttsummarydata]= datagram2timetable(datagram, metadata, summarydata)
%DATAGRAM2TIMETABLE Converts a datagram to a timetable
% TTDATAGRAM = DATAGRAM2TIMETABLE(DATAGRAM, METADATA) converts a datagram
% and associated metadata into a timetable TTDATAGRAM. This allows easy
% rasmpling of times using the retime function.
%
% [TTDATAGRAM TTSUMARYDATA] = DATAGRAM2TIMETABLE(DATAGRAM, METADATA, SUMARYDATA) indicates
% that the DATAGRAM data variable is summary data and creates a timetable
% of that instead.


if nargin<3
    summarydata=[];
else
    summarydata= summarydata(:,2:end); %remove times.
end

% size(summarydata)

minmaxtime = metadata.minmaxtime;
times  = linspace(minmaxtime(1), minmaxtime(2), length(datagram(1,:)));


%remove NAN values
[datagram,indexrmv] = removenan(datagram);
times(indexrmv)=[];

% put into a time table for easy time calculations.
ttdatagram = timetable(datetime(times, 'ConvertFrom', 'datenum')', datagram');
if (~isempty(summarydata))
    summarydata(indexrmv,:)=[]; 
    ttsummarydata = timetable(datetime(times, 'ConvertFrom', 'datenum')', summarydata);
end

end

