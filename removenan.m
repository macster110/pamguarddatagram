function [datagram,indexrmv] = removenan(datagram)
%REMOVENAN Removes NaN values form a datagram
%   Detailed explanation goes here
    % first remove NAN values if duty cycled
    indexrmv =[];
    for i=1:length(datagram(1,:))
        if sum(~isnan(datagram(:,i)))==0
            indexrmv = [indexrmv i];
        end
    end
    

    datagram(:,indexrmv) = [];
end

