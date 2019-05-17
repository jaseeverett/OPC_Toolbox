function    Compile = OPC_Compile(Compile,OPC,a,xtra)

% Compile Data

Compile.datenum(a,1) = OPC.datenum(a);
Compile.datestr(a,:) = datestr(OPC.datenum(a));

Compile.Counts(a,:) = sum(OPC.NBSS.Binned_ESD(:,2));
Compile.ParetoSlope(a,1) = OPC.Pareto.Slope;
Compile.ParetoIntercept(a,1) = OPC.Pareto.Intercept;
Compile.ParetoRsq(a,1) = OPC.Pareto.RSq;
Compile.NBSSSlope(a,1) = OPC.NBSS.Lin.Slope;
Compile.NBSSIntercept(a,1) = OPC.NBSS.Lin.Intercept;
% Compile.TotBiomass(a,1) = OPC.NBSS.TotBiomass;
Compile.Biomass(a,1) = OPC.Stats.Biomass;
Compile.TotCounts(a,1) = sum(OPC.NBSS.Binned_ESD(:,2));
Compile.AvCounts(a,1) = OPC.Stats.Counts;
Compile.GeoMn(a,1) = OPC.Stats.GeoMn;



if nargin == 4
    
    for x = 1:length(xtra)
        
        eval(['Compile.',xtra{x},'(a,:) = OPC.',xtra{x},';'])
    end
end
