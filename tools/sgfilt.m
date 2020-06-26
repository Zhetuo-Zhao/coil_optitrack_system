% this function filters the data using an SGolay filter of size k (order of
% poynomial) and F (length of the frame). You can have a filter for the
% data points or for the derivative of the datapoints by changing the value
% of dn (ex: 1 gives a filter for the derivative)
function [y,B] = sgfilt(x,k,F,dn)
flag = 0;
L = length(x);
M = (F-1)/2;
rf = -M:M;
for ii=1:F
    B(ii,:) =sgsdf(rf,k,dn,rf(ii),flag);    % last M rows for the startup duration of the signal and the first M rows for the final transient period and row equivalent to rf=0 for steady period
end
for ii=1:length(x)
   
    if ii<=M+1
        y(ii) = dot(x(1:F),B(ii,:));
    elseif ii>(L-M-1)
        y(ii) = dot(x(end-F+1:end),B(M+ii-(L-M-1),:));
    else
        y(ii) = dot(x(ii-M:ii+M),B(M+1,:));
    end
end 