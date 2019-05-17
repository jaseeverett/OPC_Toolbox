function LOPC = LOPC_Merge(files,ESD)

% Not merged yet
% Engineering data
% MEPS.Raw
%
% I am currently not merging flow

% .dat or .mat

if strcmpi(files{1}(end-2:end),'dat')
    dat = 1;
    if nargin == 1
        LOPC = LOPC_Setup(files(1));
    else
        LOPC = LOPC_Setup(files(1),ESD);
    end
else
    dat = 0;
end

if nargin == 1
    ESD = [LOPC.MinESD LOPC.MaxESD];
end

for a = 1:length(files)
    %% First we load the LOPC file (either .dat or .mat).
    if dat == 1 % If .dat, need to process
        tmp = LOPC_Setup(files{a},ESD);
        tmp = LOPC_Analyse(tmp);
        
        
         %There are a few files in IN2016v04 where the Flowmeter didn't work
        %properly. I am not sure how else to remove it, other than to
        %hardwire it here.
        if strcmpi(tmp.FileName,'LOPC/LOPC_2016-09-07_042014.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-09-06_201453.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-12_132318.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-13_072248.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-14_080524.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-17_080711.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-17_083238.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-01-31_143444.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-02-01_122240.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-02-13_012454.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-03-16_215852.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-03-17_141147.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-03-30_105359.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2016-04-06_070527.dat') == 1 | ...
                strcmpi(tmp.FileName,'LOPC/LOPC_2018-04-07_082805.dat') == 1

            tmp.Flow = rmfield(tmp.Flow,'Meter');
            
            tmp.Flow.Velocity = tmp.Flow.Transit.Velocity;
            tmp.Flow.Velocity = nan_replace(tmp.Flow.Velocity,tmp.datenum);
            
            tmp.Flow.Dist = tmp.Flow.Transit.Dist;
            tmp.Flow.Dist = nan_replace(tmp.Flow.Dist,tmp.datenum);
            
            tmp.Flow.Vol = tmp.Flow.Transit.Vol;
            tmp.Flow.Vol = nan_replace(tmp.Flow.Vol,tmp.datenum);
            
            tmp.Flow.FlowUsed = 'LOPC SEP Transit Time';
            tmp.Flow.TotalVol = sum(tmp.Flow.Vol);
            
            disp(' ')
            warning('Replacing Flowmeter with Transit Speed due to FlowMeter Probs')
            disp(tmp.FileName)
            disp(' ')
        end
        
        
    elseif dat == 0 % otherwise just load
        eval(['load ',files{a},' s'])
        tmp = s; clear s
    end
    
%     disp(['Start LOPC ',num2str(a),': ',datestr(tmp.datenum(1))])
%     disp(['End LOPC ',num2str(a),': ',datestr(tmp.datenum(end))])
%     disp([' '])
    
    % For the first file, it is just processed as usual above and here we
    % pull out the  variables we need.
    if a == 1
        LOPC.Param = tmp.Param;
        LOPC.NBSS.to_mg = tmp.NBSS.to_mg;
        LOPC.NBSS.min_count = tmp.NBSS.min_count;
        LOPC.NBSS.BinWidth = tmp.NBSS.BinWidth;
        
        LOPC.Unit = tmp.Unit;
        LOPC.Date_Extracted = datestr(now);
        
        if dat == 1
            LOPC.Processed_date = tmp.Processed_date;
        else
            LOPC.Processed_date = datestr(now);
        end
        
        LOPC.Sampling_date = tmp.Sampling_date;
        LOPC.datenum = tmp.datenum;
        
        if dat == 1
            LOPC.MergeNames{a} = tmp.FileName;
        else
            LOPC.MergeNames{a} = tmp.Output_Name;
        end
        
        if dat == 1
            LOPC.CPS = tmp.CPS;
            LOPC.SEPS = tmp.SEPS;
            LOPC.MEPS = tmp.MEPS;
        end
        
        LOPC.Binned_ESD = tmp.NBSS.all.Histo;
        
        LOPC.SMEP = tmp.SMEP;
        LOPC.Flow = tmp.Flow;
        
        if dat == 1 && isfield(tmp,'GPS')
            LOPC.Lat = tmp.GPS.Lat;
            LOPC.Lon = tmp.GPS.Lon;
        elseif dat == 0 && isfield(tmp,'latitude')
            LOPC.Lat = tmp.latitude;
            LOPC.Lon = tmp.longitude;
        end
        
        if dat == 1 && isfield(tmp,'CTD')
            LOPC.Depth = tmp.CTD.Depth;
            if isfield(tmp.CTD,'Temp')
                LOPC.Temp = tmp.CTD.Temp;
                LOPC.Salt = tmp.CTD.Salt;
            end
            
        elseif isfield('tmp','pressure')==1
            LOPC.Depth = tmp.pressure;
            LOPC.Temp = tmp.temperature;
            LOPC.Salt = tmp.salinity;
        end
        
        LOPC.FileRef = ones(size(tmp.datenum));
        
        if dat == 1
            LOPC.deltaTime = tmp.deltaTime;
        end
        
        if dat == 0
            LOPC.MinESD = tmp.LOPC.MinESD;
            LOPC.MaxESD = tmp.LOPC.MaxESD;
        end
        
    else
        LOPC.datenum = [LOPC.datenum; tmp.datenum];
        
        if dat == 1
            
            LOPC.MergeNames = [LOPC.MergeNames; tmp.FileName];
            LOPC.SEPS = [LOPC.SEPS; tmp.SEPS];
            
            % Commented out to save some time. Can be re-enabled later if needed.
            % Also commented out in LOPC_Particles
            % LOPC.MEPS.Raw_Time = [LOPC.MEPS.Raw_Time; tmp.MEPS.Raw_Time];
            LOPC.MEPS.DS = [LOPC.MEPS.DS; tmp.MEPS.DS];
            LOPC.MEPS.ESD = [LOPC.MEPS.ESD; tmp.MEPS.ESD];
            LOPC.CPS = [LOPC.CPS; tmp.CPS];
        end
        LOPC.Binned_ESD = [LOPC.Binned_ESD; tmp.NBSS.all.Histo];
        
        LOPC.SMEP = [LOPC.SMEP; tmp.SMEP];
        
        
        %% Do Flow
        
        % Volume from SEP Transit Speeds
        LOPC.Flow.Transit.Counts = [LOPC.Flow.Transit.Counts; tmp.Flow.Transit.Counts];
        LOPC.Flow.Transit.Velocity = [LOPC.Flow.Transit.Velocity; tmp.Flow.Transit.Velocity];
        LOPC.Flow.Transit.Vol = [LOPC.Flow.Transit.Vol; tmp.Flow.Transit.Vol];
        LOPC.Flow.Transit.TotalVol = sum(LOPC.Flow.Transit.Vol);
        LOPC.Flow.Transit.Dist = [LOPC.Flow.Transit.Dist; tmp.Flow.Transit.Dist];
        
%         % Volume from Flow Meter
        if isfield(tmp.Flow,'Meter') % Flow meter exists and I need to store it
            LOPC.Flow.Meter.Dist = [LOPC.Flow.Meter.Dist; tmp.Flow.Meter.Dist];
            LOPC.Flow.Meter.Velocity = [LOPC.Flow.Meter.Velocity; tmp.Flow.Meter.Velocity];
            LOPC.Flow.Meter.Vol = [LOPC.Flow.Meter.Vol; tmp.Flow.Meter.Vol];
            LOPC.Flow.Meter.TotalVol = sum(LOPC.Flow.Meter.Vol);
            LOPC.Flow.Meter.Dist = [LOPC.Flow.Meter.Dist; tmp.Flow.Meter.Dist];

        end
       

        % The determination of Flow Meter vs Transit Speed is done in LOPC_Flow
        LOPC.Flow.Velocity = [LOPC.Flow.Velocity; tmp.Flow.Velocity];  
        LOPC.Flow.Dist = [LOPC.Flow.Dist; tmp.Flow.Dist];
        LOPC.Flow.Vol = [LOPC.Flow.Vol; tmp.Flow.Vol];
        LOPC.Flow.TotalVol = sum(LOPC.Flow.Vol);

        
        %% Do GPS
        
        if dat == 1 && isfield(tmp,'GPS')
            LOPC.Lat = [LOPC.Lat; tmp.GPS.Lat];
            LOPC.Lon = [LOPC.Lon; tmp.GPS.Lon];
            
        elseif isfield(tmp,'latitude')
            LOPC.Lat = [LOPC.Lat; tmp.latitude];
            LOPC.Lon = [LOPC.Lon; tmp.longitude];
            
        end
        
        if dat == 1 && isfield(tmp,'CTD')
            LOPC.Depth = [LOPC.Depth; tmp.CTD.Depth];
            if isfield(tmp.CTD,'Temp')
                LOPC.Temp = [LOPC.Temp; tmp.CTD.Temp];
                LOPC.Salt = [LOPC.Salt;tmp.CTD.Salt];
            end
            
        elseif isfield('tmp','pressure')==1
            
            LOPC.Depth = [LOPC.Depth; tmp.pressure];
            LOPC.Temp = [LOPC.Temp; tmp.temperature];
            LOPC.Salt = [LOPC.Salt; tmp.salinity];
        end
        
        if dat == 1
            LOPC.deltaTime = [LOPC.deltaTime; tmp.deltaTime];
        end
        LOPC.FileRef = [LOPC.FileRef; zeros(size(tmp.datenum))+a];
        
    end
    
    LOPC.Check.Biomass(a,1) = tmp.Stats.Biomass;
    LOPC.Check.MnCounts(a,1) = tmp.Stats.Abundance;
    LOPC.Check.Vol(a,1) = tmp.Flow.TotalVol;
    
    disp(['LOPC',num2str(a),' Start Time: ',datestr(tmp.datenum(1))])
    disp(['LOPC',num2str(a),' End Time: ',datestr(tmp.datenum(end))])
    disp(' ')
    
    clear tmp
end

% %% I think this calculates the fitting parameters for the whole transect
LOPC = OPC_Parameters(LOPC);
LOPC = OPC_Pareto(LOPC);
LOPC = OPC_NBSS(LOPC);
