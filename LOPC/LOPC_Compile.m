function  Compile = LOPC_Compile(Compile,LOPC,a,xtra)

% Compile Data
Compile.datenum(a,1) = LOPC.Sample_datenum;
Compile.datestr(a,:) = LOPC.Sample_datestr;
Compile.datestr(a,:) = LOPC.Sample_datestr;
Compile.vol(a,1) = LOPC.Flow.TotalVol;

Compile.Counts(a,:) = sum(LOPC.NBSS.Histo);
Compile.ParetoSlope(a,1) = LOPC.Pareto.Slope;
Compile.ParetoIntercept(a,1) = LOPC.Pareto.Intercept;
Compile.ParetoRsq(a,1) = LOPC.Pareto.RSq;
Compile.NBSSSlope(a,1) = LOPC.NBSS.Lin.Slope;
Compile.NBSSIntercept(a,1) = LOPC.NBSS.Lin.Intercept;
Compile.NBSSRsq(a,1) = LOPC.NBSS.Lin.r2;

try
   Compile.NBSS_Curve(a,1) = LOPC.NBSS.NLin.Curve; 
end

Compile.Biomass(a,1) = LOPC.Stats.Biomass;
Compile.Abundance(a,1) = LOPC.Stats.Abundance;
Compile.Total_Counts(a,1) = LOPC.Stats.Total_Counts;
Compile.GeoMn(a,1) = LOPC.Stats.GeoMn;
Compile.SmlBio(a,1) = LOPC.NBSS.Binned_Bio(1);
Compile.LgBin(a,1) = LOPC.NBSS.Bins(end);
Compile.NoBins(a,1) = length(LOPC.NBSS.Bins);
% Compile.Biomass_Check(a,1) = LOPC.Stats.Biomass_Check;

Compile.NB(a,:) = LOPC.NBSS.all.NB;

if nargin == 4  
    for x = 1:length(xtra)
        eval(['Compile.',xtra{x},'(a,:) = LOPC.',xtra{x},';'])
    end
end
