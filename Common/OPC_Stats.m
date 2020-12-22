function OPC = OPC_Stats(OPC)

%% Calculate Biomass and Count data for the min/max size range

OPC.Stats.Total_Counts = length(OPC.Pareto.ESDs);
OPC.Stats.Abundance = OPC.Stats.Total_Counts./OPC.Flow.TotalVol;

OPC.Stats.Biomass = sum(OPC.NBSS.all.Binned_Bio);
OPC.Stats.BioVol = sum(OPC.NBSS.all.Binned_BioVol);

OPC.Stats.GeoMn = nangeomean(OPC.Pareto.ESDs);
OPC.Stats.GeoSD = NaN;
%     OPC.Stats.GeoSD = geostd(OPC.Pareto.ESDs);

if length(OPC.NBSS.Binned_Bio) >= 8
    OPC.Stats.SmlBio = OPC.NBSS.Binned_Bio(1);
    OPC.Stats.LgBin = OPC.NBSS.Bins(end);
else
    OPC.Stats.SmlBio = NaN;
    OPC.Stats.LgBin = NaN;
end

OPC.Stats.NoBins = length(OPC.NBSS.Bins);


