function OPC = OPC_Summarise(s,fi)

% This function takes multiple OPC files which have been stacked end to end
% and recalculated the volume, NBSS etc. At this stage it only works with
% OPC-2T and OPC-1L. It doesn't work with LOPC.

% Jason Everett (UNSW)
% WRitten: 10 May 2012;
% Updated: 21 June 2016
% Updated: 4 November 2016

% if length(s.Bins_ESD) > 50
%     error ('Check that the OPC input is not from an LOPC. OPC_Summarise only works with the OPC* Series')
% end



%%
OPC.Unit = s.Unit;
OPC.MinESD = s.MinESD;
OPC.MaxESD = s.MaxESD;

try
    OPC.MinBio = s.MinBio;
    OPC.MaxBio = s.MaxBio;
catch
    OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,3);
    OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,3);
end

OPC.Unit = s.Unit;
% OPC.Sampling_date = .Sampling_date;
% OPC.Date_Extracted = LOPC2.Date_Extracted;

OPC = OPC_Parameters(OPC);

if strcmp(s.Unit,'OPC2T') == 1 | strcmp(s.Unit,'OPC1L') == 1
    OPC.flow_mark = s.flow_mark;
    OPC.Flow.TotalVol = sum(s.vol(fi(~isinf(s.vol(fi)))));
    
    ESDs = nansum(s.Binned_ESD(fi,:));
    s.Bins = OPC_Bio2ESD(s.Bins_ESD,3);
    OPC.ESD = [];
    for i = 1:length(ESDs)
        OPC.ESD = [OPC.ESD; repmat(s.Bins_ESD(i),ESDs(i),1)];
    end
    
elseif strcmp(s.Unit,'InSituLOPC') == 1
    disp('Unit is Insitu LOPC')
    
    try
        OPC.Lat = nanmean(s.Lat);
    catch % An investigator dataset
            OPC.Lat = nanmean(s.latitude);
    end
    
    OPC.DateProcessed = datestr(now);
    
    OPC = OPC_Parameters(OPC);
    
%     OPC = LOPC_LOPCBins(OPC);
    OPC.SMEP = s.SMEP(fi,:);
    OPC.Flow.Vol = s.Flow.Vol(fi);
    OPC.Flow.TotalVol = nansum(OPC.Flow.Vol);
    
else
    error('No Unit found')
end

OPC = OPC_Pareto(OPC);
OPC = OPC_NBSS(OPC);

return















OPC.MinBio = s.Limits(1);
OPC.MaxBio = s.Limits(end);

% OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,OPC.Param.Ellipsoid);
% OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,OPC.Param.Ellipsoid);

try
    OPC.Unit = s.Unit;
catch
    OPC.Unit = 'OPC2T';
end








OPC.min_count = 1;
OPC.ESD = NaN;

OPC = OPC_Parameters(OPC);

OPC.NBSS.Binned_ESD = nansum(s.Binned_ESD(fi,:));
OPC.NBSS.Binned_Bio = OPC_ESD2Bio(OPC.NBSS.Binned_ESD,OPC.Param.Ellipsoid);
OPC.NBSS.Histo = sum(OPC.NBSS.Binned_ESD);



% OPC.NBSS.Binned_ESD = OPC.NBSS.Binned_ESD(5:end,:);

OPC.NBSS.all.Binned_ESD = OPC.NBSS.Binned_ESD;
% OPC.NBSS.Binned_ESD_orig = OPC.Binned_ESD;
OPC.NBSS.to_mg = 1e9; % to convert vol to mg (from Suthers et al 04)
OPC.NBSS.Bins = s.Bins;
OPC.NBSS.Limits = s.Limits;
OPC.Flow.TotalVol = nansum(s.vol(fi));


% OPC = OPC_NBSS(OPC);
OPC = OPC_NBSS_Calcs(OPC,'');





return

%% Original Code - I will try and incorporate LOPC now


% This function takes multiple OPC files which have been stacked end to end
% and recalculated the volume, NBSS etc. At this stage it only works with
% OPC-2T and OPC-1L. It doesn't work with LOPC.

% Jason Everett (UNSW)
% Last Modified: 21 June 2016

if length(s.Bins_ESD) > 50
    error ('Check that the OPC input is not from an LOPC. OPC_Summarise only works with the OPC* Series')
end

% OPC.NBSS.min_count = 1;
% OPC.MinESD = 265/1e6; % From MEB (limits(5))
% OPC.MaxESD = 10000/1e6;
%
% OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,3);
% OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,3);

% OPC.Unit = 'OPC2T';
% OPC.flow_mark = 1;

%%
OPC.Unit = 'OPC2T';
OPC.MinESD = s.MinESD;
OPC.MaxESD = s.MaxESD;

try
    OPC.MinBio = s.MinBio;
    OPC.MaxBio = s.MaxBio;
catch
    OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,3);
    OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,3);
end

% OPC.Unit = s.Unit;
% OPC.flow_mark = s.flow_mark;


OPC.Flow.TotalVol = sum(s.vol(fi(~isinf(s.vol(fi)))));

OPC = OPC_Parameters(OPC);


ESDs = nansum(s.Binned_ESD(fi,:));

s.Bins = OPC_Bio2ESD(s.Bins_ESD,3);

OPC.ESD = [];
for i = 1:length(ESDs)
    
    OPC.ESD = [OPC.ESD; repmat(s.Bins_ESD(i),ESDs(i),1)];
end

OPC = OPC_Pareto(OPC);
OPC = OPC_NBSS(OPC);















return

OPC.MinBio = s.Limits(1);
OPC.MaxBio = s.Limits(end);

% OPC.MinBio = OPC_ESD2Bio(OPC.MinESD,OPC.Param.Ellipsoid);
% OPC.MaxBio = OPC_ESD2Bio(OPC.MaxESD,OPC.Param.Ellipsoid);

try
    OPC.Unit = s.Unit;
catch
    OPC.Unit = 'OPC2T';
end








OPC.min_count = 1;
OPC.ESD = NaN;

OPC = OPC_Parameters(OPC);

OPC.NBSS.Binned_ESD = nansum(s.Binned_ESD(fi,:));
OPC.NBSS.Binned_Bio = OPC_ESD2Bio(OPC.NBSS.Binned_ESD,OPC.Param.Ellipsoid);
OPC.NBSS.Histo = sum(OPC.NBSS.Binned_ESD);



% OPC.NBSS.Binned_ESD = OPC.NBSS.Binned_ESD(5:end,:);

OPC.NBSS.all.Binned_ESD = OPC.NBSS.Binned_ESD;
% OPC.NBSS.Binned_ESD_orig = OPC.Binned_ESD;
OPC.NBSS.to_mg = 1e9; % to convert vol to mg (from Suthers et al 04)
OPC.NBSS.Bins = s.Bins;
OPC.NBSS.Limits = s.Limits;
OPC.Flow.TotalVol = nansum(s.vol(fi));


% OPC = OPC_NBSS(OPC);
OPC = OPC_NBSS_Calcs(OPC,'');

