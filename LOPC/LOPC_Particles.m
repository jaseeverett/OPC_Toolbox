function LOPC = LOPC_Particles(LOPC,data)

%% Check there are the L and M lines are below the header
eval('s = strfind(data,''#'');')
header_end = find(~cellfun('isempty',s)==1);

eval('t = strfind(data,''L1'');');
firstL1 = find(~cellfun('isempty',t)==1,1,'first');

header_end = header_end(find(header_end<firstL1,1,'last'));
clear s t

%% SEPS
st = [1 33 65 97 129];

for a = 1:4
    eval(['s = strfind(data,''L',num2str(a),''');'])
    ix = find(~cellfun('isempty',s)==1);
    
    if min(ix) <= header_end
        disp('Correcting for L* in the header')
        ix = ix(ix > header_end);
    end
    
    if a == 1
        LOPC.SEPS = ones(length(ix),128)*NaN;
        LOPC.MEPS.Raw.SEP_idx = ix;
    end
    temp = char(data(ix)); %temp char
    LOPC.SEPS(:,st(a):st(a+1)-1) = str2num(temp(:,3:end)); %#ok<ST2NM>
    
end
clear s temp a ix st


%% MEPS
ix = find(~cellfun('isempty',strfind(data,'M '))==1);
if min(ix) <= header_end
    disp('Correcting for ''M '' in the header')
    ix = ix(ix > header_end);
end
temp = char(data(ix)); %temp char

% m = data(strncmp(data,'M ',2));
% temp = char(m);

% IN MATLAB 2023B, there seems to be a bug whereby large numbers error in
% str2num regardless. Here I split the large ones and do it part by part
if length(temp) > 5000000
    raw_MEPS = [str2num(temp(1:5000000,3:end)); str2num(temp(5000001:length(temp),3:end))];
else
    raw_MEPS = str2num(temp(:,3:end)); %#ok<ST2NM>
end



element_offset = 32786;
st = find(raw_MEPS(:,4) > element_offset); % First element of the MEPS.
fi = [st(2:end)-1; length(raw_MEPS)];

LOPC.MEPS.Raw.ElementNo = raw_MEPS(:,1);  % Range: 0:34 actual photo-diode element blocked by MEP
LOPC.MEPS.Raw.ScanNo = raw_MEPS(:,2); % Range: 1-65535 "time of travel" reference
LOPC.MEPS.Raw.ScanLength = raw_MEPS(:,3); % Range: 1-2047 Transit time through beam
LOPC.MEPS.Raw.PeakLaser = raw_MEPS(:,4); % Range: 1-4095 Amount of laser blocked by particle
% LOPC.M.time = ;

% Need to improve MEP time
% LOPC.M.time = raw_MEPS(:,2);
% fi = find(LOPC.M.time ==  65535);

laser = raw_MEPS(:,4);
laser(st,1) = laser(st,1) - element_offset;

clear m temp raw_MEPS element_offset

%% Parameters for ESD Conversion (Per Alex Herman's Website Documentation)
LOPC.MEPS.a1 = 0.1806059;
LOPC.MEPS.a2 = 0.00025459;
LOPC.MEPS.a3 = -1.0988e-9;
LOPC.MEPS.a4 = 9.54e-15;

%% SMEPS
% Why 3000 bins?
LOPC.SMEP = [LOPC.SEPS zeros(size(LOPC.SEPS,1),LOPC.Param.xtra_bins)];

% Preallocate
LOPC.MEPS.DS  = ones(length(st),1).*NaN;
LOPC.MEPS.ESD = LOPC.MEPS.DS;
LOPC.MEPS.Raw.MEP_idx = LOPC.MEPS.DS;
LOPC.MEPS.binNo = LOPC.MEPS.DS;

for i=1:length(st)
    
    %% Find the closest SEP spot
    fs = find(LOPC.MEPS.Raw.SEP_idx <= ix(st(i)),1,'last');
    
    if ~isempty(fs)
        LOPC.MEPS.Raw.MEP_idx(i,1) = fs;
    else
        LOPC.MEPS.Raw.MEP_idx(i,1) = LOPC.MEPS.Raw.SEP_idx(1); % MEPS is the first and therefore there is no corresponding SEP
    end
    clear fs
    
    %%
    imep = st(i):fi(i); % Find all lines of an individual MEP
  
    % Commented out to save some time. Can be re-enabled later if needed.
%     LOPC.MEPS.Raw_Time(i,1) = round(mean(LOPC.MEPS.Raw.ScanNo(st(i):fi(i))));
    
    LOPC.MEPS.DS(i,1)  = sum(laser(imep)); % Digital Size
    LOPC.MEPS.ESD(i,1) = LOPC.MEPS.a1 + LOPC.MEPS.a2.*LOPC.MEPS.DS(i)...
        + LOPC.MEPS.a3.*LOPC.MEPS.DS(i).^2 + LOPC.MEPS.a4*LOPC.MEPS.DS(i).^3; % ESD in mm
    LOPC.MEPS.ESD(i,1) = LOPC.MEPS.ESD(i).*10^(3);    % Convert to um
    
    LOPC.MEPS.binNo = ceil(LOPC.MEPS.ESD(i)/15); % Calculate which Bin the MEP should go into
    
    try
        LOPC.SMEP(LOPC.MEPS.Raw.MEP_idx(i,1),LOPC.MEPS.binNo) = LOPC.SMEP(LOPC.MEPS.Raw.MEP_idx(i,1),LOPC.MEPS.binNo)+1;  % Add one to the SMEP count
    catch err
        if strcmp(err.identifier,'MATLAB:badsubscript') % There aren't enough bins for larger particles
            disp(['LOPC size limit is 3.5 cm, Measured MEP is ',num2str(LOPC.MEPS.ESD(i).*100),' cm - Ignoring'])
            disp(' ')
        else
            rethrow err
        end
        
    end
    
end

clear st fi laser


%% Now we reduce the number of bins to only be within the size range of the data

fi = find(LOPC.Param.all_H_Edges >= LOPC.MinESD,1,'first'); 
LOPC.Param.H_Bins = LOPC.Param.all_H_Bins(fi:end);
LOPC.Param.H_Edges = LOPC.Param.all_H_Edges(fi:end);
LOPC.SMEP = LOPC.SMEP(:,fi:end);
clear fi

%% Calculate CPS
LOPC.CPS = sum(LOPC.SMEP,2)./2; % Recorded every half second
