function LOPC = LOPC_BinDepths(LOPC)

% This function was written for Dave McKinnon in order to bin his data into
% 1m depth bins
% This function is only run if there is CTD data
%
% Written by Jason Everett (UNSW) November 2013
%
maxD = floor(max(LOPC.CTD.Depth));
Edge = 0:1:maxD;

LOPC.DepthBins.Depth = Edge(2:end)';

LOPC.DepthBins.Bins = LOPC.NBSS.all.Bins;
LOPC.DepthBins.Limits = LOPC.NBSS.all.Limits;

%% Reduce LOPC.SMEP to my bins (nominally 45 um)

for a = 1:length(LOPC.NBSS.all.Bins)
    
   fi = find(LOPC.Param.H_Bins > LOPC.NBSS.all.Limits(a)...
       & LOPC.Param.H_Bins < LOPC.NBSS.all.Limits(a+1));
    Binned_ESD(:,a) = sum(LOPC.SMEP(:,fi),2);
end

for a = 1:length(Edge)-1    
    fi = find(LOPC.CTD.Depth >= Edge(a) & LOPC.CTD.Depth < Edge(a+1));    
    LOPC.DepthBins.Binned_ESD(a,:) = sum(Binned_ESD(fi,:));
    LOPC.DepthBins.Vol(a,:) = sum(LOPC.Flow.Vol(fi,1));
end

clear Binned_ESD
    
% N = histc(LOPC.SMEP,Edge);
% LOPC.DepthBins.SMEP = N(1:end-1,:);

LOPC.DepthBins.Counts = sum(LOPC.DepthBins.Binned_ESD,2);

LOPC.DepthBins.Binned_ESDm3 = LOPC.DepthBins.Binned_ESD./repmat(LOPC.DepthBins.Vol,1,length(LOPC.DepthBins.Binned_ESD));


