function MLE = OPC_MLE(x)

% Calculates the negative log-likelihood of the parameters b, xmin and xmax
%  given data x for the PLB model. Returns the negative log-likelihood.
%  Will be called by nlm or similar, but xmin and xmax are just estimated as the
%  min and max of the data, not numerically using likelihood.
% Args:
%   b: value of b for which to calculate the negative log-likelihood
%   x: vector of values of data (e.g. masses of individual fish)
%   xn: length(x), have as an input to avoid repeatedly calculating it
%   xmin: minimum value of x, have as an input to avoid repeatedly calculating
%   xmax: maximum value of x, have as an input to avoid repeatedly calculating
%   sumlogx: sum(log(x)) as an input, to avoid repeatedly calculating
%
% This code was written for MATLAB by Jason Everett (UNSW). March 2019.
%
% It is transposed from Andrew Edwards github and based on the paper:
% Edwards, A. M., J. Robinson, M. J. Plank, J. Baum, and J. L. Blanchard. 2017.
% Testing and recommending methods for fitting size spectra to data.
% Methods in Ecology and Evolution 8(1):57?67.
%
% Returns:
%   negative log-likelihood of the parameters given the data.

% Test data when debugging
% x = csvread('MyData.csv');    %  Edwards data

 MLE.b = NaN;
    MLE.bSlope = NaN;
    MLE.sumlogx = NaN;
    MLE.xmin = NaN;
    MLE.xmax = NaN;
    MLE.xn = NaN;
    MLE.Output = NaN;
    MLE.Gradient = NaN;
    MLE.Hessian = NaN;
    
return


if ~isempty(x) | min(x) <= 0 | min(x) >= max(x)
    
%     if min(x) <= 0 || min(x) >= max(x)
%         error("Parameters out of bounds in negLL.PLB")
%     end
    
    sumlogx = sum(log(x));
    xmin = min(x);
    xmax = max(x);
    xn = length(x);
    
    b0 = 1/( log(min(x)) - sum(log(x))/length(x)) - 1;
    
    if (b0 ~= -1)
        fun = @(b)-xn * log( ( b + 1) / (xmax^(b + 1) - xmin^(b + 1)) ) - (b * sumlogx);
    else
        fun = @(b) xn * log( log(xmax) - log(xmin) ) + sumlogx;
    end
    
    options = optimoptions(@fminunc,'Algorithm','quasi-newton','Display','none');
    
    %More output for debugging. Not usually needed.
    % options = optimoptions(@fminunc,'Algorithm','quasi-newton','Display','iter','OptimalityTolerance',1e-10,...
    %     'StepTolerance',1e-10,'Diagnostics','on','MaxIterations',1e6);
    
    [negLogL,~,~,OUTPUT,GRAD,HESSIAN] = fminunc(fun,b0,options);
    
    MLE.b = negLogL;
    MLE.bSlope = MLE.b+1;
    MLE.sumlogx = sumlogx;
    MLE.xmin = xmin;
    MLE.xmax = xmax;
    MLE.xn = xn;
    MLE.Output = OUTPUT;
    MLE.Gradient = GRAD;
    MLE.Hessian = HESSIAN;
    
else
    MLE.b = NaN;
    MLE.bSlope = NaN;
    MLE.sumlogx = NaN;
    MLE.xmin = NaN;
    MLE.xmax = NaN;
    MLE.xn = NaN;
    MLE.Output = NaN;
    MLE.Gradient = NaN;
    MLE.Hessian = NaN;
    
end




%% This is the original R code from Edwards et al 2017 github

% negLL.PLB = function(b, x, n, xmin, xmax, sumlogx)
%   {
%   # Calculates the negative log-likelihood of the parameters b, xmin and xmax
%   #  given data x for the PLB model. Returns the negative log-likelihood. Will
%   #  be called by nlm or similar, but xmin and xmax are just estimated as the
%   #  min and max of the data, not numerically using likelihood.
%   # Args:
%   #   b: value of b for which to calculate the negative log-likelihood
%   #   x: vector of values of data (e.g. masses of individual fish)
%   #   n: length(x), have as an input to avoid repeatedly calculating it
%   #   xmin: minimum value of x, have as an input to avoid repeatedly calculating
%   #   xmax: maximum value of x, have as an input to avoid repeatedly calculating
%   #   sumlogx: sum(log(x)) as an input, to avoid repeatedly calculating
%   #
%   # Returns:
%   #   negative log-likelihood of the parameters given the data.
%   #
%     if(xmin <= 0 | xmin >= xmax) stop("Parameters out of bounds in negLL.PLB")
%     if(b != -1)
%       { neglogLL = -n * log( ( b + 1) / (xmax^(b + 1) - xmin^(b + 1)) ) -
%             b * sumlogx
%       } else
%       { neglogLL = n * log( log(xmax) - log(xmin) ) + sumlogx
%       }
%     return(neglogLL)
%   }