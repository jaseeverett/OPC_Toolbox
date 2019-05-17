function OPC = OPC_Variables(OPC)

OPC.NBSS.to_mg = 1e9; % to convert vol to mg (from Suthers et al 04)

% % Area of opening
% OPC.OPCSA = 0.02 * 0.1; %m OPC Height - 2cm  OPC Width - 10cm
% OPC.NetSA = pi * 0.1^2; % m 10cm radius of 100um plankton net
% 
% 
% if OPC.flow_mark == 1
%     OPC.TowTime = OPC.DigiTime(end) - OPC.DigiTime(1); % time in secs
%     OPC.Vol = OPC.OPCSA*(nanmean(OPC.Flow)*OPC.TowTime);
%     
%     OPC.Counts_m3 = length(OPC.ESD)/OPC.Vol;
% end
% 
% if OPC.flow_mark ~= 1 & size(OPC.Volume) == 1
%     OPC.Vol = OPC.Volume;
% end
