function  LOPC_CTD_Plot(LOPC,h)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


plot(h,LOPC.datenum,LOPC.CTD.Depth,'k')

maxD = (round(max(LOPC.CTD.Depth).*10)./10);
minD = -5;

ylim(h,[minD,maxD])

xlabel('Time')
datetick(h,'x')
ylabel('Depth')

set(h,'YDir','Reverse')


