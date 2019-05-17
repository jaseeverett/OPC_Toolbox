function NBSS = OPC_NBSS_Fit_Lin(NBSS,Weight)

lastwarn('')

if length(NBSS.Bins) < 5 || sum(NBSS.Histo) < 500 || sum(NBSS.Binned_Bio) == 0 || sum(isfinite(NBSS.NB)==0) > 0
    % if length(NBSS.Bins) < 5 || sum(NBSS.Histo) < 400 || sum(NBSS.Binned_Bio) == 0    
    NBSS = setNaN(NBSS);
    
else
    
    if license('test', 'Statistics_Toolbox') == 1
        if nargin == 1
            mdl = fitlm(log10(NBSS.Bins),log10(NBSS.NB),'linear');
        elseif nargin == 2
            mdl = fitlm(log10(NBSS.Bins),log10(NBSS.NB),'linear','weight',Weight);
        end
        
        NBSS.Lin.mdl = mdl;
        NBSS.Lin.Slope = mdl.Coefficients.Estimate(2);
        NBSS.Lin.Intercept = mdl.Coefficients.Estimate(1);
        NBSS.No_Bins_Used = length(NBSS.Histo);
        NBSS.Lin.r2 = double(mdl.Rsquared.Ordinary);
        [~, NBSS.Lin.yci] = predict(mdl,log10(NBSS.Bins'));
        NBSS.Lin.illconditioned = 0;
        
    else
        %% New fitting - Not using the statistics toolbox
        p = polyfit(log10(NBSS.Bins),log10(NBSS.NB),1);
        yfit = polyval(p,log10(NBSS.Bins));
        yresid = log10(NBSS.NB) - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(log10(NBSS.NB))-1) * var(log10(NBSS.NB));
        
        NBSS.Lin.r2 = 1 - SSresid/SStotal;
        NBSS.Lin.Slope = p(1);
        NBSS.Lin.Intercept = p(2);
        NBSS.No_Bins_Used = length(NBSS.Histo);
        NBSS.Lin.illconditioned = 0;
    end
    
    [~, LASTID] = lastwarn;
    if strcmp(LASTID,'stats:LinearModel:RankDefDesignMat')==1
        NBSS = setNaN(NBSS);
    end
    
end

function NBSS = setNaN(NBSS)

NBSS.Lin.mdl = NaN;
NBSS.Lin.Slope = NaN;
NBSS.Lin.Intercept = NaN;
NBSS.No_Bins_Used = NaN;
NBSS.Lin.r2 = NaN;
NBSS.Lin.illconditioned = 1;