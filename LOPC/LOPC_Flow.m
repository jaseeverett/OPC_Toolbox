function LOPC = LOPC_Flow(LOPC)

% Calculate flow and volume data
%
% Useage: LOPC = LOPC_Flow(LOPC)
%
%
% Writen by Jason Everett (UNSW)
% August 2013
% Updated August 2016
% Updated October 2017 to include distance calculations

%% Get Flow data from the engineering structure
LOPC.Flow.Transit.Counts = LOPC.Eng.Delta_Time./LOPC.Eng.Flow_Counts;
LOPC.Flow.Transit.Velocity = ones(length(LOPC.Flow.Transit.Counts),1).*NaN; %Preallocate

% Apply the co-efficients from Herman's documentation
for i = 1:length(LOPC.Flow.Transit.Counts)
    if LOPC.Flow.Transit.Counts(i)<=13
        f1 = 23.10410966;
        f2 = -1.481499106;
        f3 = 1.566460406;
        f4 = 0.196311142;
        f5 = -0.05;
    elseif LOPC.Flow.Transit.Counts(i)>13
        f1 = 0.198996019;
        f2 = -2.603059062;
        f3 = 0.892897609;
        f4 = 0.006191239;
        f5 = -0.0013;
    else % FC(i) must be a NaN
        f1 = NaN; f2 = NaN; f3 = NaN; f4 = NaN; f5 = NaN;
    end
    
    LOPC.Flow.Transit.Velocity(i,1) = f1.*(exp(-(f2.*sqrt(LOPC.Flow.Transit.Counts(i).^0.5)...
        + f3.*LOPC.Flow.Transit.Counts(i).^0.5 + f4.*LOPC.Flow.Transit.Counts(i)...
        + f5.*LOPC.Flow.Transit.Counts(i).^(1.5)))); % units m/s
end
clear f* i

max_flow = 10; % ms-1
LOPC.Flow.Transit.Velocity(LOPC.Flow.Transit.Velocity>max_flow) = NaN;

fi_bad = find(isnan(LOPC.Flow.Transit.Velocity)==1); % Find the bad data
fi_good = find(isnan(LOPC.Flow.Transit.Velocity)==0); % FInd the good data

% Replace bad with good
LOPC.Flow.Transit.Velocity(fi_bad) = interp1(LOPC.datenum(fi_good),...
    LOPC.Flow.Transit.Velocity(fi_good),LOPC.datenum(fi_bad),'nearest','extrap');

LOPC.Flow.Transit.Dist = LOPC.Flow.Transit.Velocity .* [diff(LOPC.secs); nanmean(diff(LOPC.secs))];


%% Calculate Volume from SEP Transit Speed
if strcmp(LOPC.Unit,'LabLOPC')==0
    LOPC.Flow.Transit.Vol = LOPC.Flow.Transit.Velocity.*LOPC.Param.SA; % units m^3/s
    % Check there are no NANs
    if isempty(find(isnan(LOPC.Flow.Transit.Vol))==0)
        LOPC.Flow.Transit.TotalVol = sum(LOPC.Flow.Transit.Vol);
    else
        error('NaN''s in LOPC.Flow.Transit.Vol')
    end
end

%% For lab-based systems - use manually calculated net volume
if strcmp(LOPC.Unit,'LabLOPC')==1 || strcmp(LOPC.Unit,'LOPC+Tunnel')==1
    % If the LabOPC is used, move the flow data into a new field for debugging
    % of flow through the LabOPC data
    LOPC.Flow_Debug = LOPC.Flow;
    LOPC = rmfield(LOPC,'Flow');
    LOPC.Flow.TotalVol = LOPC.vol;
end


%% Flow meter
if nanmean(LOPC.Eng.Electronic_Counts) > 0 % Flow meter exists and I need to store it
    LOPC.Flow.Meter.Dist = (LOPC.Param.Flow_Meter_Constant.*LOPC.Eng.Electronic_Counts);
    
    fi_bad = find(isnan(LOPC.Flow.Meter.Dist)==1); % Find the bad data
    fi_good = find(isnan(LOPC.Flow.Meter.Dist)==0); % FInd the good data
    
    LOPC.Flow.Meter.Dist(fi_bad) = interp1(LOPC.datenum(fi_good),...
        LOPC.Flow.Meter.Dist(fi_good),LOPC.datenum(fi_bad),'nearest','extrap'); % Replace bad with good
    
    
    % Time Step - Generally 0.5 secs but there may be instances where I use
    % this code for longer avearging so I made the time step variable
    dt = diff(LOPC.datenum)*86400;
    dt = [dt; dt(end)];
    
    LOPC.Flow.Meter.Velocity = LOPC.Flow.Meter.Dist ./ dt; % m s-1
    LOPC.Flow.Meter.Vol = LOPC.Flow.Meter.Velocity.*LOPC.Param.SA;
    clear dt
    
    if isempty(find(isnan(LOPC.Flow.Meter.Vol))==0)
        LOPC.Flow.Meter.TotalVol = sum(LOPC.Flow.Meter.Vol);
    else
        error('NaN''s in LOPC.Flow.Meter.Vol')
    end
end

%% Only useful for vertical profiles. Turn off for the moment.

if isfield(LOPC.Flow,'Meter')
    LOPC.Flow.Dist = LOPC.Flow.Meter.Dist;
    LOPC.Flow.Velocity = LOPC.Flow.Meter.Velocity;
    LOPC.Flow.Vol = LOPC.Flow.Meter.Vol;
    LOPC.Flow.TotalVol = LOPC.Flow.Meter.TotalVol;
    LOPC.Flow.FlowUsed = 'Flowmeter';
    
elseif ~strcmp(LOPC.Unit,'LabLOPC')  % Logger but no CTD
    LOPC.Flow.FlowUsed = 'LOPC SEP Transit Time';
    
    % Otherwise use the LOPC derived flow speeds
    LOPC.Flow.Dist = LOPC.Flow.Transit.Dist;
    LOPC.Flow.Velocity = LOPC.Flow.Transit.Velocity;
    LOPC.Flow.Vol = LOPC.Flow.Transit.Vol;
    LOPC.Flow.TotalVol = LOPC.Flow.Transit.TotalVol;
    
else
    LOPC.Flow.FlowUsed = 'Manually entered Volume - LabLOPC';
end

if LOPC.Flow.TotalVol == 0
    error('Total Volume filtered is 0 m3')
end

