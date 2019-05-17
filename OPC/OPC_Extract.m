function OPC = OPC_Extract(file,in)
%
% This function loads the binary .d00 file and creates a structure with the
% fields
%   OPC.d00_date - The date the d00 file was created, extracted from the file
%   OPC.Raw.ID - ID of data type
%   OPC.Raw.Value - Data Value for corresponding Data ID
%
% From OPC structure we extract/calculate time, flow, light attentuation,
% counts, digital size and ESD.
%
% The field IDs are:    1 = Digital Size,
%                       2 = Light Att,
%                       3 = 0.5sec interval,
%                       5 = Depth
%                       8 = Flow
%                       9 = Sound Speed (Only found in Russ Hopcroft Data)
%
% Useage: OPC = OPC_Extract(file,minESD,maxESD,bins,flow_mark)
%
%   where file is the filename as a string (including the extension .d00) and
%   minESD/maxESD (optional) is the min and max size of OPC particles to be
%   considered for analysis. The default size range is everything above 400um.
%
% Flow_mark = 0 (No flow + But NaNs filled in)
% Flow_mark = 1 (Flowmeter)
% Flow_mark = 2 (No flow and left blank)
% Flow_mark = 3 (Total Volume passed to this function)
%
% This function also cal
%   OPC_read_d00
%   OPC_OPC_Digi2ESD
%   OPC_calc_flow
%   OPC_Bin
%   OPC_NBSS
%   OPC_Pareto
%   OPC_Spatial
%
% TO DO:
% OPC_NBSS - Calculate NBSS
% OPC_Pareto - Calculate Pareto
%
% Written by Jason Everett (UNSW).
% 22nd May 2008

disp(' ')
disp(['Processing ',file,' via OPC_Extract'])

%% Set Range for Analysis %%

OPC = OPC_read_d00(file);

if isfield(OPC,'GPS') && isfield(in,'GPS')
    in = rmfield(in,'GPS');
end

OPC = merge_struct(OPC,in);

if isfield(in,'flow_mark')==0
    OPC.Flow.flow_mark = NaN; % OPC flow_mark unknown at this point
else
    OPC.Flow.flow_mark = in.flow_mark;
    OPC = rmfield(OPC,'flow_mark');
end

if isfield(in,'save')==0
    OPC.save = 1; % Default to saving the data
end

if isfield(in,'Split')==0
    OPC.Split = 0; % Default to no splitting of sample
end

clear in

OPC = OPC_SurfaceArea(OPC);

%% Convert from digital size to the ESD %%
OPC.ESD = OPC_Digi2ESD(OPC.DigiSize);

% Depth doesn't exist in OPC-1L
if ~isempty(OPC.Depth)
    OPC = OPC_Extract_Depth(OPC);
else
    OPC = rmfield(OPC,'Depth');
end

%% Add in time as matlab datenum format
OPC.datenum = datenum(OPC.d00_date) + OPC.DigiTime./86400;

OPC.secs_diff = [NaN; diff(OPC.datenum.*86400)];
OPC.secs_diff(1) =  nanmean(OPC.secs_diff);

OPC.secs = (OPC.datenum-OPC.datenum(1)).*86400;

if isfield(OPC,'User') & OPC.Flow.flow_mark~=2% At this stage, not all files apply the 'User' file prior to this point. I will fix this u pin a later version
    %% If these conditions are met, it is likely that the VDV Acoustic and GO Flow Meter are on the OPC
    if strcmp(OPC.User,'Hopcroft')==1 && (isfield(OPC.Raw,'ID12')==1 || isfield(OPC.Raw,'ID13')==1)
        
        % First do VDV
        OPC = MissLink_Hopcroft_VDV(OPC);
        
        % Then start on GO
        OPC.Flow.RawCounts = OPC.Raw.ID12;
        
    else
        OPC.Flow.RawCounts = OPC.Raw.ID8;
    end
    
    % Hopcroft Flowmeter uses different co-efficients
    m = 0.13;
    b = 0.037;
    OPC.Flow.Velocity = (m * OPC.Flow.RawCounts + b) ./100; % m/s
    OPC.Flow.Vol = OPC.SA.*OPC.Flow.Velocity; % (m3/s)
    OPC.Flow.TotalVol = nansum(OPC.Flow.Vol);
    OPC.Flow.FlowUsed = 'FlowMeter';
    OPC.Flow.flow_mark = 5;
    
    OPC.Flow.Dist = OPC.Flow.Velocity .* OPC.secs_diff;
end



%% Flow calculations updated on 8th August 2016 to remove all the if and elseifs

if OPC.Flow.flow_mark ~= 5 && (OPC.Flow.flow_mark == 1 || isfield(OPC.Flow,'RawCounts')==1) % Flowmeter
    
    OPC.Flow.Velocity = OPC_CalcFlow(OPC.Flow.RawCounts);
    OPC.Flow.Vol = OPC.SA.*OPC.Flow.Velocity; % (m3/s)
    OPC.Flow.TotalVol = nansum(OPC.Flow.Vol);
    OPC.Flow.FlowUsed = 'Flowmeter';
    
    OPC.Flow.flow_mark = 1;
    
elseif OPC.Flow.flow_mark == 2 % No flow, don't fill
    
    % Do nothing
    disp('No data for flow')
    OPC.Flow.TotalVol = NaN;
    
elseif OPC.Flow.flow_mark == 3 % Volume passed in
    
    if OPC.Split ~= 0
        OPC.vol = OPC.vol * 1/(2^OPC.Split);
    end
    
    OPC.Flow.TotalVol = OPC.vol;
    OPC.Flow.FlowUsed = 'RecordedVolume';
    OPC = rmfield(OPC,'vol');
    
elseif OPC.Flow.flow_mark == 4 % VDV Flowmeter
    
    OPC.Flow.Vol = OPC.SA.*OPC.Flow.Velocity; % (m3/s)
    OPC.Flow.TotalVol = nansum(OPC.Flow.Vol);
    OPC.Flow.FlowUsed = 'VDV Flowmeter';
    
    
elseif OPC.Flow.flow_mark == 0 || isnan(OPC.Flow.flow_mark) % No flow - fill with NaNs
    OPC.Flow.Velocity = OPC.DigiTime.*NaN;
    %     OPC.Flow.flow_mark= 0;
    disp('No data for flow - Filling with NaNs')
    
end


%% Load OPC Paramters
OPC = OPC_Parameters(OPC);

%% Calculate Pareto
OPC = OPC_Pareto(OPC);


if OPC.Flow.flow_mark == 1 || OPC.Flow.flow_mark == 3
    %% Bin the data
    OPC = OPC_Bin(OPC);
    
    %  Calculate NBSS
    OPC = OPC_NBSS(OPC);
end

%% OPC Stats

% Save the structure with the original name of 'file'
if OPC.save == 1
    eval(['save ',file(1:end-4),'.mat OPC'])
end



function OPC = OPC_Extract_Depth(OPC)

OPC.RawDepth = OPC.Depth;
OPC = rmfield(OPC,'Depth');

%% Change OPC Depth sensor to Depth (m)
if isfield(OPC,'DepthCal') == 1
    m = OPC.DepthCal.m;
    b = OPC.DepthCal.b;
else
    m = 100;
    b = -100;
end

voltage = 5 * (OPC.RawDepth./4095);

P = m * voltage + b;

% if ~isfield(OPC,GPS)
%     OPC.Depth = -gsw_z_from_p(P,OPC.Lat);
% else
OPC.Depth = -gsw_z_from_p(P,OPC.GPS.Lat(1));
% end
OPC.Depth(OPC.Depth<0) = NaN;
