function LOPC = LOPC_Analyse(LOPC)

% The main guts of the LOPC software. Performs all the analysis after
% loading required parameters from the GUI or user scripts.
%
% LOPC should have the following fields as a minimum:
% LOPC.MinESD
% LOPC.MaxESD
%
% Jason Everett January 2013

% TODO Add the Bin ranges for all SEPS and MEPS and SMEPS
% How to incorporate MEPS correctly into SEPS - We do not know the exact
% time the MEP is recorded. They are not printed into the datastream
% until there is some spare time


%% Check structure
% It must contain: Bins, Edges and FileName
if isfield(LOPC,'FileName') == 0
     msgbox('No FileName Specified')
end

%% Variables
fid = fopen(LOPC.FileName,'r');

LOPC.Date_Extracted = datestr(now);
C = textscan(fid, '%s','delimiter','\n');
data = C{1}; clear C

%% Get required info from LOPC Header
LOPC = LOPC_Header(LOPC,data);

LOPC = OPC_Parameters(LOPC);

%% Process SEPS, MEPS and SMEPS
LOPC = LOPC_Particles(LOPC,data);

%% Time
LOPC.datenum = datenum(LOPC.Sampling_date) + ([0.5:0.5:size(LOPC.SEPS,1)/2]'-0.5)./86400;
LOPC.secs = LOPC.datenum.*86400 - LOPC.datenum(1).*86400;

%% GPS Data
LOPC = LOPC_GPS(LOPC,data);

if isfield(LOPC,'GPS') == 1
    if ~isempty(find(isnan(LOPC.GPS.Lat)==1,1))
        % Replace missing NaNs
        LOPC.GPS.Lat = fillmissing(LOPC.GPS.Lat,'linear');
        LOPC.GPS.Lon = fillmissing(LOPC.GPS.Lon,'linear');   
    end
end
%% Load CTD data
LOPC = LOPC_CTD(LOPC,data);

%% Engineering Data
LOPC = LOPC_Engineer(LOPC,data);

%% Calculate Flow Speed
LOPC = LOPC_Flow(LOPC);

LOPC.deltaTime = diff(LOPC.datenum);  %d-1
LOPC.deltaTime(length(LOPC.deltaTime)+1,1) = nanmean(LOPC.deltaTime);

%% Running Abundance
if strcmp(LOPC.Unit,'LabLOPC') == 0
    LOPC.Abund = sum(LOPC.SMEP,2) ./ LOPC.Flow.Vol;
end
%% Pareto
LOPC = OPC_Pareto(LOPC);
% LOPC = LOPC_Pareto_Plot(LOPC);

%% NBSS
LOPC = OPC_NBSS(LOPC);
% 

%% Surface Area of Opening
LOPC = OPC_SurfaceArea(LOPC);


% if isfield(LOPC,'CTD')
%     LOPC = LOPC_VertBiomass(LOPC);
% end

% disp('LOPC_DepthBins.m disabled at the moment')
% if isfield(LOPC,'CTD') == 1
%     LOPC = LOPC_BinDepths(LOPC);
% end

fclose(fid);

disp('Finished processing LOPC file')
disp('**********************')
disp(' ')
