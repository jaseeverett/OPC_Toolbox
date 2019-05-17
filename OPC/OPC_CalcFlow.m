function Velocity = OPC_CalcFlow(Flow)
%
% OPC_CalcFlow calculates the flow rate (m/s) from the raw flow data saved
% by the OPC.
%
% Useage: Flow = OPC_CalcFlow(Raw_Flow)
%
% Written by Jason Everett (UNSW) June 2008
% Equations adapted from Appendix A of the OPC Users Manual
% The Optical Plankton Counter is a product of Focal Technologies.


%% Replace zero flows with last +ve one %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for xx = 1:size(Flow,1)
%     if Flow(xx) > 0
%         yy = xx;
%     elseif Flow(xx) == 0 || Flow(xx) == inf
%         Flow(xx) = Flow(yy);
%     end
% end
% clear xx yy

x = 1:length(Flow);

fi_bad = find(Flow==0);
fi_good = find(Flow>0);

if ~isempty(fi_bad)
    Flow(fi_bad) = interp1(x(fi_good),Flow(fi_good),x(fi_bad),'nearest');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For the General Oceanics GO2031H with standard rotor:
m = 0.13;
b = 0.037;
x = 7200./Flow; % (Hz)
Velocity = m * x + b; % m/s



