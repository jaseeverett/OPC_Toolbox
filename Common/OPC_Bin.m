 function OPC = OPC_Bin(OPC)
%
% OPC_Bin bins the OPC ESD Data according to limits (bin edges).
%
% Here we create 3 types of binned distributions
%   1. OPC.NBSS.all. - All the bins from the very smallest bin through to the largest
%   recorded by the OPC.
%   2. OPC.NBSS.red. - All the bins from minESD to maxESD
%   3. OPC.NBSS - This is initially identical to OPC.NBSS.red, but will later be
%   reduced further depending on minimum counts. This is what is used for
%   NBSS calculations.
%
% Useage: OPC = OPC_Bin(OPC)
%
% Written by Jason Everett (UNSW). 
% 22nd May 2008
% Updated: December 2013
% Updated: March 2015
% Updated: September 2015 with new Bin categories

%%
% Check OPC.Limits is one number longer than OPC.Bins
if diff([length(OPC.NBSS.all.Limits) length(OPC.NBSS.all.Bins)]) ~= -1
    error('Problem with the size of OPC.Limits or OPC.Bins')
end

%% 1. All NBSS Bins
% h = histc(OPC.Pareto.all.ParBio,OPC.NBSS.all.Limits)'; % I changed this
% on 21/3/2017. I removed the .all. from the Pareto data as we don't want
% to include particles which are smaller than the min OPC size.

h = histc(OPC.Pareto.ParBio,OPC.NBSS.all.Limits)';
if isempty(h)
    h = zeros(1,length(OPC.NBSS.all.Limits));
end

if size(h,2)==1; h = h'; end

OPC.NBSS.all.Histo = [h(1:end-2) h(end)+h(end-1)];
OPC.NBSS.all.Binned_Bio = (OPC.NBSS.all.Histo .* OPC.NBSS.all.Bins)./OPC.Flow.TotalVol;
OPC.NBSS.all.Binned_BioVol = (OPC.NBSS.all.Histo.*OPC.NBSS.all.Bins_BioVol)./OPC.Flow.TotalVol;
    
% %% 2. Reduced NBSS Bins
% h = histc(OPC.Pareto.ParBio,OPC.NBSS.red.Limits)';
% if size(h,2)==1; h = h'; end
% 
% if ~isempty(h)
%     OPC.NBSS.red.Histo = [h(1:end-2) h(end)+h(end-1)];
%     OPC.NBSS.red.Binned_Bio = (OPC.NBSS.red.Histo.*OPC.NBSS.red.Bins)./OPC.Flow.TotalVol;
%     OPC.NBSS.red.Binned_BioVol = (OPC.NBSS.red.Histo.*OPC.NBSS.red.Bins_BioVol)./OPC.Flow.TotalVol;
%     clear h fi
% else
%     OPC.NBSS.red.Histo = OPC.NBSS.red.Bins_ESD.*0;
%     OPC.NBSS.red.Binned_Bio = OPC.NBSS.red.Bins_ESD.*0;
%     OPC.NBSS.red.Binned_BioVol = OPC.NBSS.red.Bins_ESD.*0;
%     clear h fi
% end

%% 3. NBSS Bin  s to use
h = histc(OPC.Pareto.ParBio,OPC.NBSS.Limits)';

if size(h,2)==1; h = h'; end

if isempty(h)
    OPC.NBSS.Histo = OPC.NBSS.Bins_ESD.*0;
elseif ~isempty(h) && h(end) ~= 0 % Add the last col to the 2nd last (The last col is 'on the edge'
    OPC.NBSS.Histo = [h(1:end-2) h(end)+h(end-1)];
else
    OPC.NBSS.Histo = h(1:end-1);
end
clear h
    
% Find first value less than the min_count
fi_min = find(OPC.NBSS.Histo<OPC.NBSS.min_count,1,'first');

if isempty(fi_min) | OPC.NBSS.Histo == 0
    OPC.NBSS.Binned_Bio = (OPC.NBSS.Histo.*OPC.NBSS.Bins)./OPC.Flow.TotalVol;
    OPC.NBSS.Binned_BioVol = (OPC.NBSS.Histo.*OPC.NBSS.Bins_BioVol)./OPC.Flow.TotalVol;

else
    OPC.NBSS.Bins_ESD = OPC.NBSS.Bins_ESD(1:fi_min-1);
    OPC.NBSS.Limits_ESD = OPC.NBSS.Limits_ESD(1:fi_min);
    
    OPC.NBSS.Bins = OPC.NBSS.Bins(1:fi_min-1);
    OPC.NBSS.Limits = OPC.NBSS.Limits(1:fi_min);
    
    OPC.NBSS.Bins_BioVol = OPC.NBSS.Bins_BioVol(1:fi_min-1);
    OPC.NBSS.Limits_BioVol = OPC.NBSS.Limits_BioVol(1:fi_min);
    
    OPC.NBSS.Histo = OPC.NBSS.Histo(1:fi_min-1);
    OPC.NBSS.BinWidth = OPC.NBSS.BinWidth(1:fi_min-1);
    OPC.NBSS.Binned_Bio = (OPC.NBSS.Histo.*OPC.NBSS.Bins)./OPC.Flow.TotalVol;
    OPC.NBSS.Binned_BioVol = (OPC.NBSS.Histo.*OPC.NBSS.Bins_BioVol)./OPC.Flow.TotalVol;

end
