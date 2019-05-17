function h = OPC_Pareto_Plot(LOPC,Lim,ax,txt)

% if nargin < 3
%     error('Not enough inputs in LOPC_Pareto_Plot')
% end
% 

if nargin == 1
    ax = axes;
    Lim = 0;
    txt = 10;
elseif nargin == 2
    ax = axes;
    txt = 10;
elseif nargin == 3
    txt = 10;
end
    
if length(Lim) == 1
    Lim = [10^-4 10^-2 10^-5 10^0];
end
    
% disp('Plotting Pareto')

h = loglog(ax,LOPC.Pareto.Dist(:,1),LOPC.Pareto.Dist(:,2),'.k');

grid(ax,'on');
hold(ax,'on');
box(ax,'on')

if length(Lim) > 1
    set(ax,'XTick',10.^(log10(Lim(1)):log10(Lim(2))),...
        'YTick',10.^(log10(Lim(3)):log10(Lim(4))))
    
    set(ax,'xlim',[Lim(1) Lim(2)],'ylim',[Lim(3) Lim(4)])
end
grid(ax,'on')

xlabel(ax,'Zooplankton Size Class (ESD)','fontsize',txt)
ylabel(ax,'Probability','fontsize',txt)

set(gca,'fontsize',txt)