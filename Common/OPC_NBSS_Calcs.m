function OPC = OPC_NBSS_Calcs(OPC,sub)

% Extract the sub-structure I want to use.
NBSS = eval(['OPC.NBSS',sub,';']);

% Normalised Biomass
NBSS.NB = NBSS.Binned_Bio./NBSS.BinWidth;

if isempty(sub)
    %% Linear Model %%
    NBSS = OPC_NBSS_Fit_Lin(NBSS);
    
    %% NonLinear Model %%
    NBSS = OPC_NBSS_Fit_NLin(NBSS);
    
end

eval(['OPC.NBSS',sub,'= NBSS;'])