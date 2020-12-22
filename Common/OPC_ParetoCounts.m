function OPC = OPC_ParetoCounts(OPC)

%% Calculate total number of counts and reduce to individual counts for Pareto
if strcmp(OPC.Unit,'OPC2T')==1 ||  strcmp(OPC.Unit,'OPC1T')==1
    OPC.Pareto.ESDs = sort(OPC.ESD,'ascend');    
    
else
    
    OPC.Pareto.Binned_Counts = (sum(OPC.SMEP,1,'omitnan'))'; % Get counts for all time
    OPC.Pareto.ESDs = ones(sum(OPC.Pareto.Binned_Counts,'omitnan'),1).*NaN;

    if isfield(OPC.Param,'H_Bins')==0 && isfield(OPC,'FileBins') == 0
        OPC.Param.H_Bins = OPC.Param.all_H_Bins(end-(size(OPC.SMEP,2)-1):end);
        OPC.Param.H_Edges = OPC.Param.all_H_Edges(end-size(OPC.SMEP,2):end); 
    elseif isfield(OPC,'FileBins') == 1
        OPC.Param.H_Bins = OPC.FileBins.all_Bins_ESD;
        OPC.Param.H_Limits = OPC.FileBins.all_Limits_ESD;
    end
    
    if length(OPC.Param.H_Bins) ~= size(OPC.SMEP,2)
        error('Error in length of SMEP in OPC_ParetoCounts')
    end
    
    OPC.Pareto.ESDs = OPC_UnWrapBins(OPC.Pareto.Binned_Counts,OPC.Param.H_Bins);  
end

OPC.Pareto.ESDs = OPC.Pareto.ESDs(OPC.Pareto.ESDs>=OPC.MinESD & OPC.Pareto.ESDs<=OPC.MaxESD);
OPC.Pareto.ParArea = pi .* (OPC.Pareto.ESDs./2).^2;
[OPC.Pareto.ParBio, OPC.Pareto.ParVol] = OPC_ESD2Bio(OPC);
