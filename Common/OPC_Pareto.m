function OPC = OPC_Pareto(OPC)

lastwarn('')% Clear warnings

OPC = OPC_ParetoCounts(OPC);
OPC.Pareto.Dist = ones(length(OPC.Pareto.ESDs),2).*NaN;

sizesorts = length(OPC.Pareto.ESDs);

OPC.Pareto.Dist(:,1) = sort(OPC.Pareto.ESDs); % Size ESD
OPC.Pareto.Dist(1,2) = 1; % 100% for first

OPC.Pareto.Dist(2:sizesorts,2) = (sizesorts-(2:sizesorts))/(sizesorts-1); % Probability of size occurance

X = log10(4/3*pi*(OPC.Pareto.Dist(1:end-1,1)/2).^3);
Y = log10(OPC.Pareto.Dist(1:end-1,2));

if ~isempty(Y)
    
    if license('test', 'Statistics_Toolbox') == 1
        mdl = fitlm(X,Y,'linear');
        OPC.Pareto.mdl = mdl;
        OPC.Pareto.Intercept = mdl.Coefficients.Estimate(1);
        OPC.Pareto.Slope = mdl.Coefficients.Estimate(2);
        OPC.Pareto.RSq = OPC.Pareto.mdl.Rsquared.Ordinary;
        OPC.Pareto.illconditioned = 0;
    else
        p = polyfit(X,Y,1);
        
        OPC.Pareto.mdl = p;
        OPC.Pareto.Intercept = p(2);
        OPC.Pareto.Slope = p(1);
        
        yfit = polyval(p,log10(NBSS.Bins));
        yresid = log10(NBSS.NB) - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(Y)-1) * var(Y);
        OPC.Pareto.RSq = 1 - SSresid/SStotal;
        OPC.Pareto.illconditioned = 0;
        
    end
    
    [~, LASTID] = lastwarn;
    if strcmp(LASTID,'stats:LinearModel:RankDefDesignMat')==1
        OPC = setNaN(OPC);
    end
    
else
    OPC = setNaN(OPC);
    
end



function OPC = setNaN(OPC)
OPC.Pareto.Intercept = NaN;
OPC.Pareto.Slope = NaN;
OPC.Pareto.RSq = NaN;
OPC.Pareto.illconditioned = 1;