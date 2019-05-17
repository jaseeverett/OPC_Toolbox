function OPC = OPC_NBSS(OPC)

if isfield(OPC.NBSS,'Bins') == 0 || isfield(OPC.NBSS,'Limits') == 0
    disp('No Bins and/or limits preloaded - Defaulting to OPC Bins')
    OPC = OPC_Parameters(OPC);
end

if ~isfield(OPC.NBSS,'Alt')
    OPC.NBSS.Alt = 0;
end

OPC = OPC_Bin(OPC);

%% NBSS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The biomass in each size category is divided by the size
% range (in mg) of the category
% Biomass = [Bin Count Limit1 Limit2];

% NBSS from max counts to first zero count
OPC = OPC_NBSS_Calcs(OPC,'');

% Save the original data with all bins
% OPC = OPC_NBSS_Calcs(OPC,'.red');

% Save the original data with all bins
OPC = OPC_NBSS_Calcs(OPC,'.all');

OPC = OPC_Stats(OPC);




%% Maximum Likelihood calculations

% I'm going to temporarily put the MLE code here so it is automatically
% used by all my OPC code. In the long run I would prefer to have it as a
% seperate call, as per OPC_NBSS and OPC_Pareto

OPC.MLE = OPC_MLE(OPC.Pareto.ParBio);



