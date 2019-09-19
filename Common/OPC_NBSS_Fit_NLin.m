function NBSS = OPC_NBSS_Fit_NLin(NBSS,Weight)

lastwarn('')

  NBSS.NLin.mdl = NaN;
    NBSS.NLin.YVertex = NaN;
    NBSS.NLin.XVertex = NaN;
    NBSS.NLin.Curve = NaN;
    NBSS.NLin.r2 = NaN;
    NBSS.NLin.illconditioned = 1;
    
    return
    
    

% Turn warnings off. If the warning occurs, the state is recorded below.
warning('off','stats:LinearModel:RankDefDesignMat')
warning('off','stats:nlinfit:IllConditionedJacobian')

if license('test', 'Statistics_Toolbox') == 0
 
    NBSS = setNaN(NBSS);


elseif length(NBSS.Bins) < 5 || sum(NBSS.Histo) < 500 || sum(NBSS.Binned_Bio) == 0 || sum(isfinite(NBSS.NB)==0) > 0

    NBSS = setNaN(NBSS);
    
else
    options = statset('MaxIter',2000,'TolFun',1e-4,'TolX',1e-4);
    guess0 = [max(log10(NBSS.NB)) min(log10(NBSS.Bins)) -0.6];
    
    if length(NBSS.NB) ~= length(NBSS.Bins)
        error('Size of NB is not the same as the NBSS Bins')
    end
    
    if nargin == 1
        try
            nlm = fitnlm(log10(NBSS.Bins),log10(NBSS.NB),@dickie_fit,guess0,'options',options);
        catch
            paused
        end
      
    elseif nargin == 2
        nlm = fitnlm(log10(NBSS.Bins),log10(NBSS.NB),@dickie_fit,guess0,'options',options,'Weights',Weight);
    end
    
    if length(NBSS.Bins) ~= length(nlm.Fitted)
        error('Length of NLin Fit is incorrect ')
    end
    
    NBSS.NLin.mdl = nlm;
    NBSS.NLin.YVertex = nlm.Coefficients.Estimate(1);
    NBSS.NLin.XVertex = nlm.Coefficients.Estimate(2);
    NBSS.NLin.Curve = nlm.Coefficients.Estimate(3);
    NBSS.NLin.r2 = double(nlm.Rsquared.Ordinary);
    [~, NBSS.NLin.yci] = predict(nlm,log10(NBSS.Bins'));
    NBSS.NLin.illconditioned = 0;
    
       [~, LASTID] = lastwarn;
    if strcmp(LASTID,'stats:LinearModel:RankDefDesignMat')==1 || strcmp(LASTID,'stats:nlinfit:IllConditionedJacobian')==1 
        NBSS = setNaN(NBSS);
    end 
end

warning('on','stats:LinearModel:RankDefDesignMat')
warning('on','stats:nlinfit:IllConditionedJacobian')

function NBSS = setNaN(NBSS)
    NBSS.NLin.mdl = NaN;
    NBSS.NLin.YVertex = NaN;
    NBSS.NLin.XVertex = NaN;
    NBSS.NLin.Curve = NaN;
    NBSS.NLin.r2 = NaN;
    NBSS.NLin.illconditioned = 1;
    