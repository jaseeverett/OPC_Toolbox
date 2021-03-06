function out = OPC_NBSS_Plot(OPC,Lim,h,legend,txt,varargin)

% Usage: [h1,h2,h3,h,tx] = OPC_NBSS_Plot(OPC,Lim,h,legend,txt,varargin)
% where OPC is the structure of data and parameters generated by
% OPC_Analyse, Lim are the axes limits required for the final figure and h
% is the handle of the figure to plot to.
% h1, h2 and h3 are the handles of the raw data (h1), linear fit (h2) and
% nonlinear fit if used (h3).
%
% Default axes limits:
%     Lim = [10^-2 10^1 10^-2 10^4];
%
% Written by Jason Everett (UNSW)
% Last Updated August 2015

% legend = 1;

if nargin >= 6
    varargin_match
end

if nargin < 5
    txt = 10;
end

if nargin < 4
    legend = 1;
end

if nargin < 3
    figure
    h = axes;
end

if nargin < 2
    Lim =  0;
end

if length(Lim) == 1
    Lim = [10^-3 10^2 10^-2 10^4];
end

% OPC.NBSS
out.h1 = loglog(h,OPC.NBSS.Bins,OPC.NBSS.NB,'+k');
hold(h,'on')

% Linear Fit
if isnan(OPC.NBSS.Lin.Slope)==0
    out.h2 = loglog(h,OPC.NBSS.Bins,10.^(OPC.NBSS.Lin.mdl.Fitted),'-k');
    % Linear CI
    yci_bin = [OPC.NBSS.Bins fliplr(OPC.NBSS.Bins)];
    yci_ci = [10.^(OPC.NBSS.Lin.yci(:,1))' fliplr(10.^(OPC.NBSS.Lin.yci(:,2))')];
    out.lin_CI = fill(yci_bin,yci_ci,'k','edgecolor','none','facealpha',0.2);
    
else
    out.h2 = NaN;
end
% disp('Not plotting Non-linear - Its incorrect....')


if isfield(OPC.NBSS,'NLin')
    if isnan(OPC.NBSS.NLin.Curve)==0
        
        % % NonLinear Fit
        out.h3 = loglog(h,OPC.NBSS.Bins,10.^(OPC.NBSS.NLin.mdl.Fitted),'--k');
        % NonLinear CI
        yci_bin = [OPC.NBSS.Bins fliplr(OPC.NBSS.Bins)];
        yci_ci = [10.^(OPC.NBSS.NLin.yci(:,1))' fliplr(10.^(OPC.NBSS.NLin.yci(:,2))')];
        
        out.nlin_CI = fill(yci_bin,yci_ci,'k','edgecolor','none','facealpha',0.2);
        
    else
        out.h3 = NaN;
    end
else
    out.h3 = 0; %loglog(h,0,0);
end


set(h,'XTick',10.^(log10(Lim(1)):log10(Lim(2))),...
    'YTick',10.^(log10(Lim(3)):log10(Lim(4))))
set(h,'xlim',[Lim(1) Lim(2)],'ylim',[Lim(3) Lim(4)])

%% Get Ticks and add um
XT = get(h,'XTick')';
YT = min(get(h,'YLim'));

set(h,'fontsize',txt)
ESD = OPC_Bio2ESD(XT,OPC.Param.Ellipsoid);

% ESD = (nthroot(XT/(4/3 * pi * OPC.NBSS.to_mg),3).*2).*1e3;
ESD = num2str(roundn(ESD.*1e3,-2));

XTL = get(h,'XTickLabel');

set(h,'XTickLabel','','fontsize',txt)

for a = 1:length(XTL)   
    eval(['ESD_txt = {''',XTL{a,:},''';''(',ESD(a,:),' mm)''};']); 
    out.tx(a) = text(XT(a),YT,ESD_txt,'horizontalalignment','center','verticalalignment','top','Parent',h,'fontsize',txt);
    clear ESD_txt
end

grid(h,'on')

xlabel(h,{'';'';'Zooplankton Size Class (mg)'},'fontsize',txt)
ylabel(h,'Normalised Biomass (m^{-3})','fontsize',txt)

if legend == 1
    out.an = OPC_NBSS_Plot_Legend(OPC,txt-2);
end
out.h = h;

