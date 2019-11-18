clear
close all

%% 100um net used

% Assuming ~100% net retention using a 3:1 ellipsoid ratio, the MinESD for the following net meshes are needed:
% 100um mesh, 3:1 L:W = 173um
% 200um mesh, 3:1 L:W = 346um
% You can test other combinations using Commong/OPC_NetRetention.m

data_dir = 'Data';
figure_dir = 'Figures';
output_dir = 'Output';

FileList = {[data_dir,filesep,'Test1.dat']; [data_dir,filesep,'Test2.dat']};

fig = 1; % Plot figures or not?

MinESD = 200/1e6;
MaxESD = 30000/1e6; % 30 mm - Theoretical max is 35 mm
Ellipsoid = 3; % What ratio of Major:Minor axis of plankton to assume
min_count = 1; % Minimum number of counts in a bin before that bin is ignored in the NBSS calculations

%% Account for splits in the sample.
% If no splits, no_splits column should be 0
% csv file should have form
% filename, tow_vol_m3, no_splits
Split = readtable([data_dir,filesep,'LOPC_Metadata.csv']);


%% Process Files
for a = 1:length(FileList)
    LOPC.FileName = FileList{a};
    sf = strfind(LOPC.FileName,filesep);
    
    LOPC.ShortName = LOPC.FileName(sf(end)+1:end);
    
    LOPC.MinESD = MinESD;
    LOPC.MaxESD = MaxESD; % 30 mm - Theoretical max is 35 mm
    LOPC.Param.Ellipsoid = Ellipsoid;
    LOPC.NBSS.min_count = min_count;
    
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
        
        % Check if export_fig is installed
        if exist('export_fig.m','file') == 2
            export_fig(out_name,'-pdf')
        else
            warning('export_fig not installed. Saving figure using built in MATLAB print. You would get better results with export_fig')
            print(out_name,'-dpdf')
        end
        
        % Now do a compilation of all figures
        out_name = [figure_dir,filesep,'All_Sites'];
        if exist('export_fig.m','file') == 2
            if a ==1
                export_fig(out_name,'-pdf')
            else
                export_fig(out_name,'-pdf','-append')
            end            
        else
            if a ==1
                print(out_name,'-dpdf')
            else
                print(out_name,'-dpdf','-append')
            end
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
