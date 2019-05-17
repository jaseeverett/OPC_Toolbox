function LOPC = LOPC_Average(files)








if iscellstr(files) == 0
    error('Input variable to LOPC_Average must be cell string of filenames')
end

%% Create LOPC data structure




%% Compile the required variables

for a = 1:length(files)
    
    eval(['load ',files{a},''])
    
    maxD(a,1) = length(LOPC.Vert.Depth_Bins);
    
    vol(a,1) = LOPC.Flow.TotalVol;
    SMEP(a,:) = sum(LOPC.SMEP);
    
    Biomass(a,1) = LOPC.NBSS.Biomass;
    Counts(a,1) = LOPC.NBSS.Counts;
    
    
    %% Do vertical structure if it exists
    
    if isfield(LOPC,'Vert')
        
        if maxD(a) == maxD(1)
            VertBio(a,:,:,:) = LOPC.Vert.Binned_Biomass;
        else
            VertBio(a,:,:,:) = VertBio(a-1,:,:,:).*NaN; % Create dummy variable
            VertBio(a,1:maxD(a),:,:) = LOPC.Vert.Binned_Biomass; % Fill in the extra
        end
    end
    
    
    
    try
        BB(:,a) = LOPC.NBSS.Binned_Biomass(1:15,2);
    catch
        BB(:,a) = ones(15,1).*NaN;
    end
    
end




%% Reduce the size back to the min/max size range


%% Create LOPC structure
LOPC2 = LOPC;
clear LOPC

LOPC.MinESD = LOPC2.MinESD;
LOPC.MaxESD = LOPC2.MaxESD;
LOPC.Lat = LOPC2.Lat;
LOPC.Path = LOPC2.Path;
LOPC.Unit = LOPC2.Unit;
LOPC.Sampling_date = LOPC2.Sampling_date;
LOPC.Date_Extracted = LOPC2.Date_Extracted;

clear LOPC2

LOPC.DateProcessed = datestr(now);

LOPC = LOPC_Parameters(LOPC);
LOPC = LOPC_LOPCBins(LOPC);
LOPC.SMEP = sum(SMEP,1);
LOPC.Flow.TotalVol = sum(vol);

%% Rerun through LOPC Software
LOPC = LOPC_Pareto(LOPC);
LOPC = LOPC_NBSS(LOPC);

LOPC.VertBio = squeeze(nanmean(VertBio));
LOPC.VertBio_SD = squeeze(nanstd(VertBio));
LOPC.VertBio_SE = squeeze(nanste(VertBio));


% Add in compiled raw data
LOPC.Raw.Files = files;
LOPC.Raw.vol = vol;
LOPC.Raw.SMEP = SMEP;

LOPC.NBSS.Binned_Biomass(1:15,2);
