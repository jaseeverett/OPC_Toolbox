function LOPC = LOPC_CTD(LOPC,data)

% Load CTD data
%
% CTD data doesn't seem to be logged every timestep. It appears to be every
% 2-3 timepts. Therefore we need to interporlate this data onto the SMEP
% datastream. We do this by finding the closest L5 values, using their
% time, to infer a CTD time. Then I interp the CTD data onto the SMEP time.
%
% Following this, depth, salinity and density values are calculated based
% upon the sw toolbox. I need to update this to use the new McDougall
% toolbox.
%
% Jason Everett (UNSW) January 2013
% Last updated August 2019

% Find end of the header
eval('s = strfind(data,''#'');')
header_end = find(~cellfun('isempty',s)==1);
eval('t = strfind(data,''L1'');');
firstL1 = find(~cellfun('isempty',t)==1,1,'first');
header_end = header_end(find(header_end<firstL1,1,'last'));

% Find all CTD lines
enCTD = strfind(data,'C ');
ixCTD = find(~cellfun('isempty',enCTD)==1);

% Correct for any that are in the header
if min(ixCTD) <= header_end
    ixCTD = ixCTD(ixCTD > header_end);
end

% Some CTD's (such as the SBE49) seem to reroute the GPS through
% the CTD sensor and therefore we need to remove these C-lines.
fakeCTD = strfind(data,'$G');
ixfake =  find(~cellfun('isempty',fakeCTD)==1);
ixCTD = setdiff(ixCTD,ixfake);

clear ixfake

if ~isempty(ixCTD)
    
    % Initialise CTD so the isfield commands work below.
    if isfield(LOPC,'CTD') == 0
       LOPC.CTD.Raw.Temp = [];
    end
    
    str = regexp(data(ixCTD),'[^a-zA-Z0-9 +.,\t\-]'); % Find only the rows with alphanumeric text
    ix = find(~cellfun('isempty',str)==0); % Get indexes
    
    % Redefine ixCTD to remove the incorrect rows
    ixCTD = ixCTD(ix); clear ix
    
    Len = cellfun('length',data(ixCTD)); % Find the length of each row in the cell. Corrupt CTD also have missing data.
    mLen = mean(Len);
    
    ix = find(Len > mLen-5); % Find all the cells with 5 less than the mean
    ixCTD = ixCTD(ix);
    
    temp = char(strrep(data(ixCTD),'C ',''));
    clear str ix
    
    CTD =  str2num(temp);
    clear temp
    
    ncols = size(CTD,2);
    
    
    % If CTD Model has not been defined in the prelimary scripts, try and
    % figure out what it is.
    if  isfield(LOPC.CTD,'Model') == 0
        
        % See if we can work out the CTD model. It seems to be hit and miss
        % whether the information is included in the header. Examples I have
        % seen include.
        
        en = strfind(data,'SBE 19');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            en2 = strfind(data,'SBE 19plus');
            ix2 = ~cellfun('isempty',en2)==1;
            if isempty(data(ix2))==0
                LOPC.CTD.Model = 'SBE19plus';
            elseif isempty(data(ix2))==1
                LOPC.CTD.Model = 'SBE19';
            end
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        
        en = strfind(data,'SBE19');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'SBE19';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        
        en = strfind(data,'SBE50');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'SBE50';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        en = strfind(data,'SeaBird50');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'SBE50';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        en = strfind(data,'SBE37');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'SBE37';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        en = strfind(data,'SBE 49');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'SBE49';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        en = strfind(data,'Micro CTD (AML)');
        ix = ~cellfun('isempty',en)==1;
        if isempty(data(ix))==0
            LOPC.CTD.Model = 'AML-Micro';
            disp(['CTD is identified as a ',LOPC.CTD.Model])
        end
        
        if isfield(LOPC.CTD,'Model')==0
            disp('CTD unable to be identified')
            disp(['Its data has ',num2str(ncols),' fields so guess it is:'])
            
            if ncols == 5
                disp('SBE37 (from the number of columns)')
                LOPC.CTD.Model = 'SBE37';
            elseif ncols == 7
                disp('SOLOPC? (from the number of columns)')
                LOPC.CTD.Model = 'SOLOPC';
            else
                disp('No CTD identified')
            end
        end
    end
    
    
    if strcmp(LOPC.CTD.Model,'SBE50')==1 % SBE50 % Pressure only
        LOPC.CTD.Raw.Pres = CTD(:,1);
        
    elseif strcmp(LOPC.CTD.Model,'SBE37')==1
        LOPC.CTD.Raw.Temp = CTD(:,1);
        LOPC.CTD.Raw.Cond = CTD(:,2);
        LOPC.CTD.Raw.Pres = CTD(:,3);
        LOPC.CTD.Raw.Analog = CTD(:,4); % Some analog number?
        LOPC.CTD.Raw.noSEPS = CTD(:,5); % The number of SEPS since last CTD
        
    elseif strcmp(LOPC.CTD.Model,'SBE19plus')==1
        % Some of the SBE19plus files seem to have 9 columns, but there
        % appear to be 4x LOPC columns, not 2x as there should be.
        % Therefore we ignore the final 2.
        LOPC.CTD.Raw.Temp = CTD(:,1);
        LOPC.CTD.Raw.Cond = CTD(:,2);
        LOPC.CTD.Raw.Pres = CTD(:,3);
        LOPC.CTD.Raw.Var4 = CTD(:,4);
        LOPC.CTD.Raw.Var5 = CTD(:,5);
        
        LOPC.CTD.Raw.Anolog = CTD(:,6); % Some analog number?
        LOPC.CTD.Raw.noSEPS = CTD(:,7); % The number of SEPS since last CTD
        
    elseif strcmp(LOPC.CTD.Model,'SBE19')==1
        LOPC.CTD.Raw.Temp = CTD(:,1);
        LOPC.CTD.Raw.Cond = CTD(:,2);
        LOPC.CTD.Raw.Var3 = CTD(:,3);
        LOPC.CTD.Raw.Var4 = CTD(:,4);
        LOPC.CTD.Raw.Pres = CTD(:,5);
        
        LOPC.CTD.Raw.Anolog = CTD(:,6); % Some analog number?
        LOPC.CTD.Raw.noSEPS = CTD(:,7); % The number of SEPS since last CTD
        
    elseif strcmp(LOPC.CTD.Model,'SBE49')==1
        LOPC.CTD.Raw.Temp = CTD(:,1);
        LOPC.CTD.Raw.Cond = CTD(:,2); % S/m
        LOPC.CTD.Raw.Pres = CTD(:,3); % decibars
        LOPC.CTD.Raw.Var4 = CTD(:,4);
        
        LOPC.CTD.Raw.Anolog = CTD(:,5); % Some analog number?
        LOPC.CTD.Raw.noSEPS = CTD(:,6); % The number of SEPS since last CTD
        
    elseif strcmp(LOPC.CTD.Model,'AML-Micro')==1
        LOPC.CTD.Raw.Pres = CTD(:,1);
        LOPC.CTD.Raw.Cond_mScm = CTD(:,2); % mS/cm
        LOPC.CTD.Raw.Cond = CTD(:,2)./10; % mS/cm --> S/m
        
        LOPC.CTD.Raw.Temp = CTD(:,3); % decibars
        
        LOPC.CTD.Raw.Anolog = CTD(:,4); % Some analog number?
        LOPC.CTD.Raw.noSEPS = CTD(:,5); % The number of SEPS since last CTD
        
    elseif strcmp(LOPC.CTD.Model,'SOLOPC')==1
        LOPC.CTD.Raw.Unknown1 = CTD(:,1);
        LOPC.CTD.Raw.Pres = CTD(:,2);
        LOPC.CTD.Raw.Unknown3 = CTD(:,3);
        LOPC.CTD.Raw.Unknown4 = CTD(:,4);
        LOPC.CTD.Raw.Unknown5 = CTD(:,5);
        LOPC.CTD.Raw.Unknown6 = CTD(:,6);
        LOPC.CTD.Raw.Unknown7 = CTD(:,7);
        LOPC.CTD.Raw.All = 'The variable here are just a hack to get script running';
        LOPC.CTD.Raw.Temp = (1:size(CTD,1))';
        LOPC.CTD.Raw.Cond = LOPC.CTD.Raw.Pres;
    end
    
    %% We need to create a time value for each CTD and then interp onto
    % Find the index of all SEPs
    s = strfind(data,'L5');
    ixSEP = find(~cellfun('isempty',s)==1);
    
    ixSEP = ixSEP(1:end,1); % Remove the last L5 to ensure the interp below isn't outside the time limits
    
    % Find closest SEP to each CTD in order to get the approx time
    ind = interp1(ixSEP, 1:length(ixSEP), ixCTD, 'nearest','extrap');
    LOPC.CTD.Raw.datenum = LOPC.datenum(ind);
    
    % Pressure
    LOPC.CTD.Pres = interp1q(LOPC.CTD.Raw.datenum,LOPC.CTD.Raw.Pres,LOPC.datenum);
    
    LOPC.CTD.Depth = -gsw_z_from_p(LOPC.CTD.Pres,LOPC.GPS.Lat);
    
    fi_bad = find(isnan(LOPC.CTD.Depth)==1);
    fi_good = find(isnan(LOPC.CTD.Depth)==0);
    LOPC.CTD.Depth(fi_bad) = interp1(LOPC.datenum(fi_good),LOPC.CTD.Depth(fi_good),LOPC.datenum(fi_bad),'linear','extrap');
    
    
    % Temperature and Salinity
    if strcmp(LOPC.CTD.Model,'SBE50')==0
        % Interp to get a CTD value for each timept of ESDs
        LOPC.CTD.Temp = interp1q(LOPC.CTD.Raw.datenum,LOPC.CTD.Raw.Temp,LOPC.datenum);
        
        % Conductivity - Measured in S/m (http://www.seabird.com/products/spec_sheets/37sidata.htm)
        % (10 mS/cm = 1 S/m)
        % Store Conductivity as mS/cm for the GSW toolbox conversion later on
        LOPC.CTD.Cond = interp1q(LOPC.CTD.Raw.datenum,LOPC.CTD.Raw.Cond,LOPC.datenum).*10;
        
        LOPC.CTD.Salt = gsw_SP_from_C(LOPC.CTD.Cond,LOPC.CTD.Temp,LOPC.CTD.Pres);
        
    end
    
    
    clear CTD
end

