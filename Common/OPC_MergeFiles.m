function OPC = OPC_MergeFiles(OPC,s)

% if nargin == 2
%     fi = 1:length(s.datenum);
% end

% OPC is the primary structure.
% s is the secondary OPC which is added to the bottom of OPC;

if isfield(OPC,'MinESD')% Is this the first run through
    first = 0;
else
    first = 1;
end


if first == 1
    OPC.MinESD = s.MinESD;
    OPC.MaxESD = s.MaxESD;
    OPC.Unit = s.Unit;
    OPC.min_count = 1;
    OPC.ESD = NaN;
    OPC.NBSS.to_mg = s.NBSS.to_mg;
    OPC.NBSS.Bins = s.NBSS.all.Bins;
    OPC.NBSS.Limits = s.NBSS.all.Limits;
    
    OPC.NBSS.Bins = s.NBSS.all.Bins;
    OPC.NBSS.Limits = s.NBSS.all.Limits;
    
    OPC.NBSS.Bins_ESD = s.NBSS.all.Bins_ESD;
    OPC.NBSS.Limits_ESD = s.NBSS.all.Limits_ESD;
    
    OPC.Flow.TotalVol = s.Flow.TotalVol;
    OPC.SMEP = sum(s.SMEP,1);

end

if first == 0
    OPC.SMEP = OPC.SMEP + sum(s.SMEP,1);
    OPC.Flow.TotalVol = OPC.Flow.TotalVol + s.Flow.TotalVol;
end


