function LOPC = LOPC_Header(LOPC,data)

%% Check there is a header
% This is a hack for Checkley's and Espinasse data - There is either no header or 
% a four line header with just the processing date

if strcmp(data{1}(1:2),'L1') == 1 | strcmp(data{5}(1:2),'L1') == 1
    disp('No header found in file')
    
    LOPC.Sampling_date = datestr(LOPC.TimeStart);
    LOPC.Processed_date = datestr(now);
    LOPC.Tunnel = 'Standard';
    LOPC.Unit = 'InSituLOPC';
   
    d = cell2mat(data(5));
    d = str2num(d(4:end));

    % Guess the firmware
    
    if length(d) == 10
        LOPC.FirmVer = 2.36;
    
    elseif length(d) == 9
        LOPC.FirmVer = 2.25;
    
    else
        LOPC.FirmVer = 2;
    end
    clear d
    
    
else %% Otherwise continue
    
    
    for a = 0:5
        eval(['s = strfind(data,''HdrEntry',num2str(a),''');'])
        ix = find(~cellfun('isempty',s)==1);
        d = cell2mat(data(ix));
        ix = strfind(d,'= ');
        
        eval(['LOPC.Header.Header',num2str(a),' = d(ix+2:end);'])
    end
    clear s ix
    
    % Firmware Version
    % en = strfind(data,'DSPVER='); I think i made a mistake and correct
    % version is below
    en = strfind(data,'CFXVER=');
    ix = find(~cellfun('isempty',en)==1);
    temp = char(data(ix)); %temp char
    LOPC.FirmVer = str2double(temp(end-3:end));
    clear en ix
    
    %Tunnel Type
    en = strfind(data,'# Tunnel_Type:');
    ix = find(~cellfun('isempty',en)==1);
    temp = char(data(ix)); %temp char
    clear en ix
    temp = temp(15:end);
    temp = strrep(temp,'	',''); % Remove spaces
    LOPC.Tunnel = temp;
    
    %% SARDI set their tunnel as other - not sure of the effect of this....
    if strcmp(LOPC.Tunnel,'other')==1
        disp('SARDI FIle - Changing tunnel from ''Other'' to ''LOPC+Tunnel''')
        LOPC.Tunnel = 'LOPC+Tunnel';
    end
    
    if isnan(LOPC.Tunnel)==1 & LOPC.FirmVer <= 2.24
        disp('Defaulting to Standard Tunnel')
        LOPC.Tunnel = 'Standard';
    end
    
    
    %% Query which instrument the file came from
    if cell2mat(strfind(data,'DATALOGGER HEADER')) % Data was originally loaded onto datalogger
        % Need to use the 'System Status' date
        date = datenum(data{16}(34:end),'dddd, dd mmmm, yyyy  HH:MM:SS PM');
        
        if exist('LOPC.offset','var')
            date = date+LOPC.offset/24;
        end
        
        LOPC.Sampling_date = datestr(date);
        disp(['Analysing Datalogger File: ',LOPC.FileName])
        disp([' '])
        LOPC.logger_processesd_date = datestr(datenum([data{3}(9:end) ' ' data{4}(9:end)],...
            'dddd, mmmm dd, yyyy HH:MM:SS'));
        LOPC.Processed_date = datestr(now);
        
        LOPC.Unit = 'Logger';
        
    elseif cell2mat(strfind(data,'SYS.BAUD')) & strcmpi(LOPC.Tunnel,' Standard')
        disp(['Analysing Insitu (No datalogger) LOPC File: ',LOPC.FileName])
        disp([' '])
        
        en = strfind(data,'PC DATE-TIME');
        ix = find(~cellfun('isempty',en)==1);
        
        date = datenum([data{ix+1}(9:end) ' ' data{ix+2}(9:end)],'dddd, mmmm dd, yyyy  HH:MM:SS');
        
        if exist('LOPC.offset','var')
            date = date+LOPC.offset/24;
        end
        
        LOPC.Sampling_date = datestr(date);
        LOPC.Processed_date = datestr(now);
        
        LOPC.Unit = 'InSituLOPC';
        
    elseif LOPC.FirmVer <= 2.28 & strcmpi(LOPC.Tunnel,' Standard')
        disp('Old Firmware - Assuming this is an insitu LOPC')
        disp('Press Ctrl-C now to cancel if its not ')
        disp(' ')
        
        disp(['Analysing Insitu (No datalogger) LOPC File: ',LOPC.FileName])
        disp(' ')
        
        en = strfind(data,'PC DATE-TIME');
        ix = find(~cellfun('isempty',en)==1);
        
        date = datenum([data{ix+1}(9:end) ' ' data{ix+2}(9:end)],'dddd, mmmm dd, yyyy  HH:MM:SS');
        
        if exist('LOPC.offset','var')
            date = date+LOPC.offset/24;
        end
        
        LOPC.Sampling_date = datestr(date);
        LOPC.Processed_date = datestr(now);
        
        LOPC.Unit = 'InSituLOPC';
        
    elseif cell2mat(strfind(data,'SYS.BAUD')) & strcmpi(LOPC.Tunnel,'Other')
        disp(['Analysing LOPC with FlowTude File: ',LOPC.FileName])
        disp([' '])
        
        date = datenum([data{2}(9:end) ' ' data{3}(9:end)],'dddd, mmmm dd, yyyy  HH:MM:SS');
        
        if exist('LOPC.offset','var')
            date = date+LOPC.offset/24;
        end
        
        LOPC.Sampling_date = datestr(date);
        LOPC.Processed_date = datestr(date);
        
        LOPC.Unit = 'LOPC+Tunnel';
        
    elseif cell2mat(strfind(data,'Direct to LOPC'))
        disp(['Analysing Lab LOPC File: ',LOPC.FileName])
        disp([' '])
        
        date = datenum([data{2}(9:end) ' ' data{3}(9:end)],'dddd, mmmm dd, yyyy  HH:MM:SS');
        
        if exist('LOPC.offset','var')
            date = date+LOPC.offset/24;
        end
        
        % There is no sampling date in Lab LOPC files - Use the processed date
        LOPC.Sampling_date = datestr(date);
        LOPC.Processed_date = datestr(date);
        
        LOPC.Unit = 'LabLOPC';
    end
    clear date
    
end



