clear
close all

% This script is to run LOPC_Analyse from the command line. It inserts all
% the info which would normally be added from the GUI.

LOPC.FileName = 'TestData/LOPC-Logger-McKinnon2.dat';

LOPC.MinESD = 2.49e-04;
LOPC.MaxESD = 0.002;

LOPC.MinDepth = 0;
LOPC.MaxDepth = 500;

LOPC.offset = 10; % number of hours to add to sampling time In this case I want to change it to AEST

LOPC.Lat = -64.75;

% LOPC = LOPC_LOPCBins(LOPC);

LOPC = LOPC_Analyse(LOPC);

ax = axes;
OPC_NBSS_Plot(LOPC,1,ax);

