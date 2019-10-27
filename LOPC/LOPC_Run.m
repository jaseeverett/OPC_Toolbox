clear
close all

% This script is to run LOPC_Analyse. It inserts all required info.

LOPC.FileName = '';

LOPC.MinESD = 2.49e-04; % Minimum ESD in microns. LOPC min is 100 um
LOPC.MaxESD = 0.002;  % Maximum ESD in microns. LOPC max is 35 mm

LOPC.MinDepth = 0;
LOPC.MaxDepth = 500;

LOPC.offset = 10; % number of hours to add to sampling time In this case I want to change it to AEST from UTC

LOPC.Lat = -34; % Latitude from which sample was collected. Used for pressure-depth conversion.

LOPC = LOPC_Analyse(LOPC);

figure
ax = axes;
OPC_NBSS_Plot(LOPC,1,ax);

