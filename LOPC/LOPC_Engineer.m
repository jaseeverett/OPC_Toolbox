function LOPC = LOPC_Engineer(LOPC,data)

%% Engineering Data
en = strfind(data,'L5');
ix = find(~cellfun('isempty',en)==1);
temp = char(data(ix)); %temp char
ENG = str2num(temp(:,3:end));

LOPC.Eng.Snapshot_Indicator = ENG(:,1); % Indicates if a snapshot is in progress (1) or not (0)
LOPC.Eng.Threshold = ENG(:,2);  % Lower limit on signal detection
LOPC.Eng.Sample_Number = ENG(:,3); % Counter indicating the number of samples taken
LOPC.Eng.Flow_Counts = ENG(:,4); % Number of counts within a pre-determined size range within the current 0.5 s period
LOPC.Eng.Delta_Time = ENG(:,5); % Accumulated time for all the flow counts to pass through the beam
LOPC.Eng.Buffer_Overrun = ENG(:,6); % Indicates an internal buffer overrun (0 or 1)
LOPC.Eng.Laser_Monitor = ENG(:,7); % Mean laser intensity by all 35 elements during the 0.5 s interval

if LOPC.FirmVer >= 2.25 % These fields are only available in firmware greater than 2.25
    LOPC.Eng.Electronic_Counts = ENG(:,8);
    LOPC.Eng.Count_Period = ENG(:,9);
else
    LOPC.Eng.Electronic_Counts = NaN;
    LOPC.Eng.Count_Period = NaN;
    
end

if LOPC.FirmVer >= 2.36 & size(ENG,2)==10 % These fields are only vailable in firware greater than 2.36
    LOPC.Eng.Laser_Voltage = ENG(:,10); % Laser input voltage - Changes in order to preserve consistent Laser Monitor
end

clear ENG ix temp en