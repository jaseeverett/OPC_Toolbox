function [Compile,out] = OPC_Average(data,out)

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
        if strcmp(f(end-2:end),'d00')==1 || strcmp(f(end-2:end),'D00')==1
            f = [f,'.mat'];
        end
        eval(['load ',f,' ''-mat'''])
        
    end
    
    cnt = cnt + 1;
    vol(cnt,1) = OPC.Flow.TotalVol;
%     ESD = [ESD; OPC.ESD];
    
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
        
%         Compile.Bins_Bio = OPC.NBSS.all.Binned_Biomass(:,1)';
        
        Compile.Binned_ESD = OPC.NBSS.all.Binned_ESD; 
        Compile.Binned_ESD(:,2) = Compile.Binned_ESD(:,2).*NaN;
        Compile.Binned_Biomass = OPC.NBSS.all.Binned_Biomass;
        Compile.Binned_Biomass(:,2) = Compile.Binned_Biomass(:,2).*NaN;

    end
    
    Compile.Binned_Biomass_all(:,cnt) = OPC.NBSS.all.Binned_Biomass(:,2);
    Compile.Binned_ESD_all(:,cnt) = OPC.NBSS.all.Binned_ESD(:,2);

    Compile.Vol(1,cnt) = vol(cnt,1);
    Compile.NBSS_all(:,cnt) = OPC.NBSS.all.NBSS;
    Compile.Files(cnt,:) = OPC.File_Name;
    
end
Compile.Bio = Bio;

Compile.Binned_ESD(:,2) = sum(Compile.Binned_ESD_all,2);
Compile.Binned_Biomass(:,2) = mean(Compile.Binned_Biomass_all,2);

%% Reduce the Compile.NBSS to remove min sizes and zero bins

Compile.NBSS = nanmean(Compile.NBSS_all,2); % Arithmetic Mean
Compile.NBSS_SD = nanstd(Compile.NBSS,1,2); % Standard Deviation

fi1 = find(Compile.Limits >= OPC.MinESD);
fi2 = find(Compile.NBSS == 0,1,'first')-1;

Compile.Bins = Compile.Bins(fi1:fi2);
Compile.Limits = Compile.Limits(fi1:fi2+1);
% Compile.Bins_Bio = Compile.Bins_Bio(fi1:fi2);
Compile.Binned_ESD = Compile.Binned_ESD(fi1:fi2,:);
Compile.Binned_Biomass = Compile.Binned_Biomass(fi1:fi2,:);
Compile.NBSS_all = Compile.NBSS_all(fi1:fi2,:);
Compile.NBSS = Compile.NBSS(fi1:fi2);
Compile.NBSS_SD = Compile.NBSS_SD(fi1:fi2);

Compile.Weight = (sum(Compile.NBSS>0,2))./length(Compile.Vol);

L = OPC_NBSS_Fit_Lin(Compile,Compile.Weight);
Compile.Lin = L.Lin;

N = OPC_NBSS_Fit_NLin(Compile,Compile.Weight);
Compile.NLin = N.NLin;


%% Compile old biomass and counts to get variability

Compile.Av.Bio_All = Bio;
[Compile.Av.Biomass, Compile.Av.BiomassSD, Compile.Av.BiomassSE, Compile.Av.BiomassME] = stats(Bio);

Compile.Av.GeoMean_All = GeoMean;
[Compile.Av.GeoMean, Compile.Av.GeoMeanSD, Compile.Av.GeoMeanSE] = stats(GeoMean);

Compile.Av.Counts_All = Counts;
[Compile.Av.Counts, Compile.Av.CountsSD, Compile.Av.CountsSE] = stats(Counts);

Compile.Av.Slope_All = Slope;
[Compile.Av.Slope, Compile.Av.SlopeSD, Compile.Av.SlopeSE] = stats(Slope);

Compile.Av.Intercept_All = Intercept;
[Compile.Av.Intercept, Compile.Av.InterceptSD, Compile.Av.InterceptSE] = stats(Intercept);

Compile.Av.Curve_All = Curve;
[Compile.Av.Curve, Compile.Av.CurveSD, Compile.Av.CurveSE] = stats(Curve);

Compile.Av.XVertex_All = XVertex;
[Compile.Av.XVertex, Compile.Av.XVertexSD, Compile.Av.XVertexSE] = stats(XVertex);

Compile.Av.YVertex_All = YVertex;
[Compile.Av.YVertex, Compile.Av.YVertexSD, Compile.Av.YVertexSE] = stats(YVertex);

clear a

%% Summarise the data
if nargin == 2
    
    if isfield(out,'n')
        a = length(out.n)+1;
    else
        a = 1;
    end
    
    out.OPC{a} = OPC;
    
    out.Biomass(a,1) = Compile.Av.Biomass;
    out.BiomassSD(a,1) = Compile.Av.BiomassSD;
    
    out.GeoMean(a,1) = Compile.Av.GeoMean;
    out.GeoMeanSD(a,1) = Compile.Av.GeoMeanSD;
    
    out.Counts(a,1) = Compile.Av.Counts;
    out.CountsSD(a,1) = Compile.Av.CountsSD;
    
    
    out.Slope(a,1) = Compile.Lin.Slope;
    out.Intercept(a,1) = Compile.Lin.Intercept;    
    out.XVertex(a,1) = Compile.NLin.XVertex;
    out.YVertex(a,1) = Compile.NLin.YVertex;
    out.Curve(a,1) = Compile.NLin.Curve;
    
%     
%     out.Slope(a,1) = nanmean(Compile.Av.Slope);
%     out.SlopeSD(a,1) = nanstd(Compile.Av.SlopeSD);
%     
%     out.Intercept(a,1) = nanmean(Compile.Av.Intercept);
%     out.InterceptSD(a,1) = nanstd(Compile.Av.InterceptSD);
%     
%     out.XVertex(a,1) = nanmean(Compile.Av.XVertex);
%     out.XVertexSD(a,1) = nanstd(Compile.Av.XVertexSD);
%     
%     out.YVertex(a,1) = nanmean(Compile.Av.YVertex);
%     out.YVertexSD(a,1) = nanstd(Compile.Av.YVertexSD);
%     
%     out.Curve(a,1) = nanmean(Compile.Av.Curve);
%     out.CurveSD(a,1) = nanstd(Compile.Av.CurveSD);
    
    out.n(a,1) = length(Compile.Av.Biomass);
    
    out.TotalCounts(a,1) = sum(OPC.NBSS.Histo);
    out.No_Bins(a,1) = OPC.NBSS.No_Bins_Used;

    
end



