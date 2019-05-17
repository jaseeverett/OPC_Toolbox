function OPC = OPC_Stats(OPC)

%% Calculate Biomass and Count data for the min/max size range

OPC.Stats.Total_Counts = length(OPC.Pareto.ESDs);
OPC.Stats.Abundance = OPC.Stats.Total_Counts./OPC.Flow.TotalVol;

OPC.Stats.Biomass = sum(OPC.NBSS.all.Binned_Bio);
% OPC.Stats.Biomass_Check = sum(OPC.NBSS.Binned_Bio);

OPC.Stats.BioVol = sum(OPC.NBSS.all.Binned_BioVol);
% OPC.Stats.BioVol_Check = sum(OPC.NBSS.Binned_BioVol);


if license('test', 'Statistics_Toolbox') == 1
    
    OPC.Stats.GeoMn = geomean(OPC.Pareto.ESDs);
    OPC.Stats.GeoSD = geostd(OPC.Pareto.ESDs);
    
else
    OPC.Stats.GeoMn = 10.^(nanmean(log10(r)));
    OPC.Stats.GeoSD = NaN;
end

if length(OPC.NBSS.Binned_Bio) >= 8
    OPC.Stats.SmlBio = OPC.NBSS.Binned_Bio(1);
    OPC.Stats.LgBin = OPC.NBSS.Bins(end);
else
    OPC.Stats.SmlBio = NaN;
    OPC.Stats.LgBin = NaN;
end

OPC.Stats.NoBins = length(OPC.NBSS.Bins);


