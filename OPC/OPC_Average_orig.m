function [OPC,out] = OPC_Average(data,out)

%% Compile the required variables
ESD = [];
cnt = 0;

%% Using the data instead of files

for a = 1:length(data)
    
    if isstruct(data{1})
        OPC = data{a};
        
    else
        f = data{a};
        % Check the extension is .mat. If not, change it.
        if strcmp(f(end-2:end),'d00')==1 | strcmp(f(end-2:end),'D00')==1
            f = [f,'.mat'];
        end
        eval(['load ',f,' ''-mat'''])
        
    end
    
    cnt = cnt + 1;
    vol(cnt,1) = OPC.Flow.TotalVol;
    ESD = [ESD; OPC.ESD];
    
    Bio(cnt,1) = OPC.Stats.Biomass;
    
    Counts(cnt,1) = OPC.Stats.Counts;
    GeoMean(cnt,1) = OPC.Stats.GeoMn;
    
    Slope(cnt,1) = OPC.NBSS.Lin.Slope;
    Intercept(cnt,1) = OPC.NBSS.Lin.Intercept;
    Curve(cnt,1) = OPC.NBSS.NLin.Curve;
    XVertex(cnt,1) = OPC.NBSS.NLin.XVertex;
    YVertex(cnt,1) = OPC.NBSS.NLin.YVertex;
    
    if cnt == 1
        Compile.Bins = OPC.NBSS.all.Bins;
        Compile.Limits = OPC.NBSS.all.Limits;
        
        Compile.Bins_Bio = OPC.NBSS.all.Binned_Biomass(:,1)';
    end
    
    Compile.Binned_Biomass(:,cnt) = OPC.NBSS.all.Binned_Biomass(:,2);
    Compile.Vol(1,cnt) = vol(cnt,1);
    Compile.NBSS(:,cnt) = OPC.NBSS.all.NBSS;
    Compile.Files(cnt,:) = OPC.File_Name;
    
end
Compile.Bio = Bio;


%% Reduce the Compile.NBSS to remove min sizes and zero bins

Compile.NB_Mean = nanmean(Compile.NBSS,2); % Arithmetic Mean
Compile.NB_SD = nanstd(Compile.NBSS,1,2); % Standard Deviation

fi1 = find(Compile.Limits >= OPC.MinESD);
fi2 = find(Compile.NB_Mean == 0,1,'first')-1;

Compile.Bins = Compile.Bins(fi1:fi2);
Compile.Limits = Compile.Limits(fi1:fi2+1);
Compile.Bins_Bio = Compile.Bins_Bio(fi1:fi2);
Compile.Binned_Biomass = Compile.Binned_Biomass(fi1:fi2,:);
Compile.NBSS = Compile.NBSS(fi1:fi2,:);
Compile.NB_Mean = Compile.NB_Mean(fi1:fi2);
Compile.NB_SD = Compile.NB_SD(fi1:fi2);

%% Create OPC structure
OPC2 = OPC;
clear OPC

OPC.MinESD = OPC2.MinESD;
OPC.MaxESD = OPC2.MaxESD;
OPC.DateProcessed = datestr(now);
OPC.NBSS.min_count = OPC2.NBSS.min_count;
OPC.Unit = OPC2.Unit;

OPC.NBSS.all.Bins = OPC2.NBSS.all.Bins;
OPC.NBSS.all.Limits = OPC2.NBSS.all.Limits;
OPC.Flow.TotalVol = sum(vol);
OPC.ESD = ESD; clear ESD



%% Rerun through OPC Software
OPC = OPC_Parameters(OPC);
OPC = OPC_Pareto(OPC);
OPC = OPC_Bin(OPC);
OPC = OPC_NBSS(OPC);

%% Compile old biomass and counts to get variability

OPC.Av.Bio_All = Bio;
[OPC.Av.Biomass, OPC.Av.BiomassSD, OPC.Av.BiomassSE, OPC.Av.BiomassME] = stats(Bio);

OPC.Av.GeoMean_All = GeoMean;
[OPC.Av.GeoMean, OPC.Av.GeoMeanSD, OPC.Av.GeoMeanSE] = stats(GeoMean);

OPC.Av.Counts_All = Counts;
[OPC.Av.Counts, OPC.Av.CountsSD, OPC.Av.CountsSE] = stats(Counts);

OPC.Av.Slope_All = Slope;
[OPC.Av.Slope, OPC.Av.SlopeSD, OPC.Av.SlopeSE] = stats(Slope);

OPC.Av.Intercept_All = Intercept;
[OPC.Av.Intercept, OPC.Av.InterceptSD, OPC.Av.InterceptSE] = stats(Intercept);

OPC.Av.Curve_All = Curve;
[OPC.Av.Curve, OPC.Av.CurveSD, OPC.Av.CurveSE] = stats(Curve);

OPC.Av.XVertex_All = XVertex;
[OPC.Av.XVertex, OPC.Av.XVertexSD, OPC.Av.XVertexSE] = stats(XVertex);

OPC.Av.YVertex_All = YVertex;
[OPC.Av.YVertex, OPC.Av.YVertexSD, OPC.Av.YVertexSE] = stats(YVertex);


OPC.Compile = Compile;
clear a


%% Summarise the data
if nargin == 2
    
    if isfield(out,'n')
        a = length(out.n)+1;
    else
        a = 1;
    end
    
    out.OPC{a} = OPC;
    
    out.Biomass(a,1) = OPC.Av.Biomass;
    out.BiomassSD(a,1) = OPC.Av.BiomassSD;
    
    out.GeoMean(a,1) = OPC.Av.GeoMean;
    out.GeoMeanSD(a,1) = OPC.Av.GeoMeanSD;
    
    out.Counts(a,1) = OPC.Av.Counts;
    out.CountsSD(a,1) = OPC.Av.CountsSD;
    
    out.Slope(a,1) = nanmean(OPC.Av.Slope);
    out.SlopeSD(a,1) = nanstd(OPC.Av.SlopeSD);
    
    out.Intercept(a,1) = nanmean(OPC.Av.Intercept);
    out.InterceptSD(a,1) = nanstd(OPC.Av.InterceptSD);
    
    out.XVertex(a,1) = nanmean(OPC.Av.XVertex);
    out.XVertexSD(a,1) = nanstd(OPC.Av.XVertexSD);
    
    out.YVertex(a,1) = nanmean(OPC.Av.YVertex);
    out.YVertexSD(a,1) = nanstd(OPC.Av.YVertexSD);
    
    out.Curve(a,1) = nanmean(OPC.Av.Curve);
    out.CurveSD(a,1) = nanstd(OPC.Av.CurveSD);
    
    out.n(a,1) = length(OPC.Compile.Vol);
    
end
