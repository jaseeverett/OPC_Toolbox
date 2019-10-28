clear
close all

%% 100um net used
% OPC_NetRetention
% 3:1 L:W = 173um

data_dir = 'Data';
figure_dir = 'Figures';
output_dir = 'Output';

FileList = {'Data/File1.dat'; 'Data/File2.dat'; 'Data/File3.dat'};

fig = 1; % Plot figures or not?

%% Account for splits in the sample.
% If no splits, no_splits column should be 0
% csv file should have form
% filename, tow_vol_m3, no_splits
Split = readtable([data_dir,filesep,'LOPC_Metadata.csv']);

%% Process Files
for a = 1:length(FileList)
    
    LOPC.MinESD = 200/1e6;
    LOPC.Param.Ellipsoid = 3; % What ratio of Major:Minor axis of plankton to assume
    
    LOPC.MaxESD = 30000/1e6; % 30 mm - Theoretical max is 35 mm
    LOPC.NBSS.min_count = 1;
    
    LOPC.offset = 10; % number of hours to add to sampling time In this case I want to change it to AEST from UTC
    
    LOPC.Lat = -34; % Latitude from which sample was collected. Used for pressure-depth conversion.
    
    LOPC.FileName = FileList{a};
    sf = strfind(LOPC.FileName,'/');
    
    LOPC.ShortName = LOPC.FileName(sf(end)+1:end);
    
    %%
    % Match up the splits with the files
    s = find(strcmp(Split.filename, LOPC.ShortName(1:end-4))==1);
    if isempty(s)
        error('s empty')
    end
    
    LOPC.tow_vol = Split.tow_vol_m3(s);
    LOPC.Split = 1/(2^Split.no_splits(s));
    LOPC.vol = LOPC.tow_vol * LOPC.Split;
    
    %%
    % Flow flag. Do not change for Lab-LOPC
    flow_mark = 3; % Use given volume
    
    %% Process LOPC
    LOPC = LOPC_Analyse(LOPC);
    
    % Plot NBSS
    if fig == 1
        ax = axes;
        txt = 12;
        Lim = [10^-3 10^3 10^-2 10^4];
        
        h = OPC_NBSS_Plot(LOPC,Lim,ax,1,txt);
        
        try
            h.h3.Visible = 'off';
            h.nlin_CI.Visible = 'off';
        catch
        end
        
        ti = title(LOPC.ShortName(1:end-4),'Interpreter','none');
        set(gcf,'color','w')
        
        warning off
        out_name = [figure_dir,filesep,LOPC.ShortName(1:end-4)];
        export_fig(out_name,'-pdf')
        
        out_name = [figure_dir,filesep,'All_Sites'];
        
        if a ==1
            export_fig(out_name,'-pdf')
        else
            export_fig(out_name,'-pdf','-append')
        end
        warning on
        close all
        
    end
    
    save([output_dir,filesep,LOPC.ShortName(1:end-4),'.mat'],'LOPC')
    
    LOPC_OutputCSV(LOPC,[output_dir,filesep,LOPC.ShortName(1:end-4)])
    
    %%
    Compile.FileName{a,1} = LOPC.ShortName;
    
    Compile.Volume(a,1) = LOPC.Flow.TotalVol;
    Compile.Split(a,1) = LOPC.Split;
    Compile.MinESD(a,1) = LOPC.MinESD*1e6;
    Compile.MaxESD(a,1) = LOPC.MaxESD*1e6;
    
    Compile.ParetoSlope(a,1) = LOPC.Pareto.Slope;
    Compile.NBSS_Slope(a,1) = LOPC.NBSS.Lin.Slope;
    Compile.NBSS_Intercept(a,1) = LOPC.NBSS.Lin.Intercept;
    Compile.NBSS_r2(a,1) = LOPC.NBSS.Lin.r2;
    
    Compile.Total_Counts(a,1) = LOPC.Stats.Total_Counts;
    Compile.Abundance_indm3(a,1) = LOPC.Stats.Abundance;
    Compile.Biomass_mgm3(a,1) = LOPC.Stats.Biomass;
    Compile.GeometricMeanSize(a,1) = LOPC.Stats.GeoMn.*1e6;
    
    
    clear LOPC
end


tbl = struct2table(Compile);
writetable(tbl,[output_dir,filesep,'LOPC_Summary.csv']);



