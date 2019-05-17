function OPC = OPC_Spatial(OPC,AvgTime,Res)

% This function calculates running averages of the OPC at a given
% resolution (Res - secs) and over an average timeframe (AvgTime - secs).
% The default is a calculation every 5 secs over 30 second running average.

% disp('Running OPC_Spatial.m')
% 
% if nargin == 1 % use default
%     AvgTime = 30; % secs
%     Res = 5; % secs
% end
% 
% AvgTime = AvgTime/86400;
% Res = Res/86400;
% 
% count = 1;
% 
% % Calculate running averages every AvgTime secs
% for i = OPC.datenum(1):Res:OPC.datenum(end)
%     
%     % Correct for being too close to either end of dataset
%     if i <= OPC.datenum(1)+AvgTime;
%         f = find(OPC.datenum <= OPC.datenum(1)+AvgTime);
%         
%     elseif i >= OPC.datenum(end)-AvgTime
%         f = find(OPC.datenum >= OPC.datenum(end)-AvgTime);
%         
%     else
%         f = find((OPC.datenum >= i-AvgTime/2) & (OPC.datenum <= i+AvgTime/2));
%     end
%     
%     % Reduce OPC Structure to send to OPC_NBSS.m
%     min_size = max([30 length(f)-1]); % Ignore fields smaller than 30
%     int_OPC = reduce_struct(OPC,f,min_size);
%     
%     int_OPC = OPC_Bin(int_OPC);
%     
%     int_OPC = OPC_NBSS(int_OPC);
%     int_OPC = OPC_Pareto(int_OPC);
%     
%     RunTotBiomass(count,1) = int_OPC.TotBiomass;
%     RunCount(count,1) = size(f,1);
%     RunNBSS_Slope(count,1) = int_OPC.NBSS_Slope;
%     RunPareto_Slope(count,1) = int_OPC.Pareto_Slope;
%     RunTime(count,1) = int_OPC.datenum(1);
%     RunNoBins(count,1) = int_OPC.No_Bins_Used;
%     
%     try % Not all samples will have depth
%         RunMn_Depth(count,1) = mean(int_OPC.Depth);
%     catch
%         % Do nothing
%     end
%     
%     count = count + 1;
%     clear int_OPC
%     
% end
OPC.Run_TotBiomass = NaN; %RunTotBiomass;
OPC.Run_Count = NaN; %RunCount;
OPC.Run_NBSS_Slope = NaN; %RunNBSS_Slope;
OPC.Run_Pareto_Slope = NaN; %RunPareto_Slope;
OPC.Run_datenum = NaN; %RunTime;
OPC.Run_Mn_Depth = NaN; %RunMn_Depth;
OPC.Run_No_Bins_Used = NaN; %RunNoBins;
