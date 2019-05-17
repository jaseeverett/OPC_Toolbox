function LOPC = LOPC_ReduceDepths(LOPC)

% Reduce the LOPC structure to exclude certain depths.
% This should be run before any calls to Pareto, NBSS etc
%
% Written by Jason Everett (UNSW)
% August 2013

fi = find(LOPC.CTD.Depth >= LOPC.MinDepth & LOPC.CTD.Depth <= LOPC.MaxDepth);

LOPC.datenum = LOPC.datenum(fi);

LOPC.SMEP = LOPC.SMEP(fi,:);
LOPC.SEPS = LOPC.SEPS(fi,:);

if isstruct(LOPC.CTD) == 1
    LOPC.CTD = reduce_struct(LOPC.CTD,fi);
end
    






