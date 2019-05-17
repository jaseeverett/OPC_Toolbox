function OPC = OPC_Parameters(OPC)

% Misc Parameters
%
% Create the Bin Limits for the SMEP dataset
%
% Written by Jason Everett (UNSW) January 2013
% Updated: August 2013
% Updated: March 2015
% Updated with new Bins September 2015
% Updated: March 2017. I am removing the '.red.' bins and changing all to
% start at the min size. It seems silly to include particles we don't
% believe are correct.

% Common Parameters
OPC.NBSS.to_mg = 1e9; % to convert vol to mg (from Suthers et al 04)

% When binning, what's the minimum count to accept
if isfield(OPC.NBSS,'min_count') == 0
    OPC.NBSS.min_count = 2; %(1 and 0 counts will be removed);
end

if ~isfield(OPC,'Param')
    OPC.Param.Ellipsoid = 3;
end

if ~isfield(OPC.Param,'Ellipsoid')
    OPC.Param.Ellipsoid = 3;
end

OPC.Param.Flow_Meter_Constant = 0.134365;

incr = 0.2; % Bin increment

%
if isfield(OPC,'FileBins')
    all_Limits = OPC.FileBins.all_Limits;
    all_Bins = OPC.FileBins.all_Bins;    
else
    all_Limits = 10.^(...
        log10(OPC_ESD2Bio(100/1e6,OPC.Param.Ellipsoid))...
        :incr:...
        log10(OPC_ESD2Bio(10000/1e6,OPC.Param.Ellipsoid)));
    
    all_Bins = 10.^(...
        log10(all_Limits(1))+(incr/2)...
        :incr:...
        log10(all_Limits(end))-(incr/2));
    
end

OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,OPC.Param.Ellipsoid);
OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,OPC.Param.Ellipsoid);

fi_min = find(all_Limits >= OPC.MinBio,1,'first');
fi_max = find(all_Limits <= OPC.MaxBio,1,'last');

% Save the valid bins in case I need to reduce a pre-existing matrix of bin counts
% The -1 is because fi_max relates to limits, not the actual bin
if isfield(OPC,'FileBins')
    OPC.FileBins.ValidBins = fi_min:fi_max-1;
end

OPC.NBSS.all.Bins = all_Bins(fi_min:fi_max-1);
OPC.NBSS.all.Limits = all_Limits(fi_min:fi_max);

OPC.NBSS.all.BinWidth = diff(OPC.NBSS.all.Limits);

OPC.NBSS.all.Limits_BioVol = OPC.NBSS.all.Limits./OPC.NBSS.to_mg;
OPC.NBSS.all.Bins_BioVol = OPC.NBSS.all.Bins./OPC.NBSS.to_mg;

OPC.NBSS.all.Limits_ESD = OPC_Bio2ESD(OPC.NBSS.all.Limits,OPC.Param.Ellipsoid);
OPC.NBSS.all.Bins_ESD = OPC_Bio2ESD(OPC.NBSS.all.Bins,OPC.Param.Ellipsoid);

if strcmp(OPC.Unit,'OPC2T')==1
    % Nothing included for OPC2T or OPC1L yet
    
elseif strcmp(OPC.Unit,'InSituLOPC')==1 || strcmp(OPC.Unit,'LabLOPC')==1 || strcmp(OPC.Unit,'Logger')==1 || strcmp(OPC.Unit,'LOPC')==1
    OPC.Param.xtra_bins = 3000; % Bins for SMEPS
    
    OPC.Param.all_H_Bins = ((7.5:15:15*(128+OPC.Param.xtra_bins))./1e6);
    OPC.Param.all_H_Edges = ((0:15:15*(length(OPC.Param.all_H_Bins)))./1e6);
    
    OPC = OPC_SurfaceArea(OPC);
    OPC.Param.SA = OPC.SA;
    
end

% %% Reduce NBSS Bins to min/max as defined in OPC
%
% fi_min = find(OPC.NBSS.all.Limits >= OPC.MinBio,1,'first');
% fi_max = find(OPC.NBSS.all.Limits <= OPC.MaxBio,1,'last');
%
% OPC.NBSS.red.Bins = OPC.NBSS.all.Bins(fi_min:fi_max-1);
% OPC.NBSS.red.Limits = OPC.NBSS.all.Limits(fi_min:fi_max);
% OPC.NBSS.red.BinWidth = diff(OPC.NBSS.red.Limits);
%
% OPC.NBSS.red.Limits_BioVol = OPC.NBSS.red.Limits./OPC.NBSS.to_mg;
% OPC.NBSS.red.Bins_BioVol = OPC.NBSS.red.Bins./OPC.NBSS.to_mg;
%
% OPC.NBSS.red.Limits_ESD = OPC_Bio2ESD(OPC.NBSS.red.Limits,OPC.Param.Ellipsoid);
% OPC.NBSS.red.Bins_ESD = OPC_Bio2ESD(OPC.NBSS.red.Bins,OPC.Param.Ellipsoid);


OPC.NBSS.Bins = OPC.NBSS.all.Bins;
OPC.NBSS.Limits = OPC.NBSS.all.Limits;
OPC.NBSS.BinWidth = diff(OPC.NBSS.Limits);
OPC.NBSS.Limits_ESD = OPC_Bio2ESD(OPC.NBSS.Limits,OPC.Param.Ellipsoid);
OPC.NBSS.Bins_ESD = OPC_Bio2ESD(OPC.NBSS.Bins,OPC.Param.Ellipsoid);

OPC.NBSS.Limits_BioVol = OPC.NBSS.all.Limits./OPC.NBSS.to_mg;
OPC.NBSS.Bins_BioVol = OPC.NBSS.all.Bins./OPC.NBSS.to_mg;