function OPC = OPC_read_d00(file)
%
% This function reads the OPC files created by OPCdas software. The data is
% outputed in a structure named OPC as detailed below.
% OPC can then be run through calculate_OPC to extract flow, light
% attentuation, counts, digital size and ESD.
%
% Useage: OPC = OPC_read_d00(file)
%
% Output:   A structure - OPC with the following fields:
%           OPC.d00_date - The date the d00 file was created, extracted from the file
%          	OPC.Raw.ID - ID of data type where:
%             1 = Digital Size, 2 = Light Att, 3 = 0.5sec interval, 5 = Depth, 8 = Flow
%           OPC.Raw.Value - Data Value for corresponding Data ID

% Written by Jason Everett (UNSW) November 2007
% Updated - June 2008
% Equations adapted from Appendix A of the OPC Users Manual
% The Optical Plankton Counter is a product of Focal Technologies.

OPC.FileName = file;

%% Short filename
fi = strfind(file,'/');
fi2 = strfind(file,' ');
if isempty(fi2)
    fi2 = size(file,2) + 1;
end

OPC.ShortFile =  file(fi(end)+1:fi2-1);
OPC.Processed_Date = datestr(now);
OPC.Processed_By = 'Jason Everett (UNSW)';
OPC.Processed_Script = 'OPC_read_d00.m';

if strcmp(file(end-2),'D')==1 || strcmp(file(end-2:end),'OPC')==1 % Binary file
    
    fid = fopen(file, 'r', 'b');
    if fid == -1
        error('File does not exist')
    end
    
    %Got to end of file
    fseek(fid,0,1);
    
    % Byte number of end of file
    eof = ftell(fid);
    
    %Go back to start of file
    fseek(fid,0,-1);
    
    
    % The following information regarding data format were taken from Page 6 of
    % the OPC Users Manual (October 2001) or worked out by the author.
    Header = (fread(fid, 24,'*char'))';
    %
    
    %%    CODE WHEN I WAS TRYING TO WORK OUT WHAY ALL THE ID=15
    %     start = 27; % Start position of OPC Data
    %     fseek(fid,start,'bof');
    %     [data,count] = fread(fid, 'ubit4');
    %
    
    
    % Rearrange the OPC Header to give a meaningful date
    OPC.d00_date = ['',Header(9:10),'-', Header(5:7),'-',Header(21:24),' ',Header(12:19),''];
    clear Header
    
    % Find start position in file for OPC data
    start = 27; % Start position of OPC Data
    fseek(fid,start,'bof'); % Move to the start position
    a = 1;
    GPS_counter = 0;
    while a >= 1
        
        try
            %             ftell(fid)
            OPC.Raw.ID(a,1) = fread(fid, 1,'ubit4'); %First 4 bits are ID of data type
            
            %If incorrect ID number, don't increase a, and then the next
            %loop will overwrite the previous value.
            if OPC.Raw.ID(a,1) == 0 || OPC.Raw.ID(a,1) > 14
                %                 disp(['RawID = ',num2str(OPC.Raw.ID(a,1))])
                warning('Incorrect OPC ID Number')               
                
                %
                %                 loc = ftell(fid);
                %                 status = fseek(fid,-1,0);
                %                 fread(fid, 1,'ubit4')
                %                 loc2 = ftell(fid)
                
            elseif OPC.Raw.ID(a)==14
                GPS_error = 0;
                %                 POSITION = ftell(fid)
                
                Lat = fscanf(fid, '%c',10);
                Gap = fscanf(fid, '%c',1);
                Lon = fscanf(fid, '%c',11);
                xtra = fscanf(fid, '%c',1);
                clear xtra
                %                 POSITION2 = ftell(fid)
                
                if strcmp(Lat(end),'N')==0 && strcmp(Lat(end),'S')==0
                    disp(['GPS at line ',num2str(a),' is incorrect'])
                    GPS_error = 1;
                    GPS_error_line = a;
                end
                
                if strcmp(Lon(end),'E')==0 && strcmp(Lon(end),'W')==0
                    disp(['GPS at line ',num2str(a),' is incorrect'])
                    GPS_error = 1;
                end
                
                if GPS_error == 0
                    GPS_counter = GPS_counter + 1;
                    OPC.Raw_GPS{GPS_counter,:} = [Lat(1:10),Gap,Lon(1:11)]; % Save separately.
                    OPC.Raw.Value(a) = 99999999999999; % Replace with marker
                    a = a + 1;
                end
                
            else
                OPC.Raw.Value(a,1) = fread(fid, 1, 'ubit12'); % Next 12 bits are data value
                a = a + 1;
            end
            
        catch
            % Assume it saved an ID but not data for the last line of the binary file
            if length(OPC.Raw.ID)~= length(OPC.Raw.Value)
                OPC.Raw.ID = OPC.Raw.ID(1:end-1,1);
            end
            break
        end
    end
    
    
    % Save as .t00 file similar to the OPCdas software - But not the GPS -
    % Just a place holder. I will come back one day and add it in.
    eval(['dlmwrite(''',file(1:end-4),'.t',file(end-1:end),''',[OPC.Raw.ID OPC.Raw.Value])'])
    fclose(fid);
    
elseif strcmp(file(end-2),'T')==1 % Text file
    
    %
    fid = fopen(file);
    t = textscan(fid,'%s/n','delimiter',',');
    OPC.d00_date = datenum(t{1},'ddd mmm dd HH:MM:SS yyyy');
    fclose(fid);
    
    fid = fopen(file);
    C = textscan(fid, '%f,%s','delimiter','\n','headerlines',1);
    OPC.Raw.ID = C{1};
    fclose(fid);
    
    % GPS are string characters so its hard to import with all the other data
    fi_GPS = find(OPC.Raw.ID == 14); % Find them
    OPC.Raw_GPS = C{2}(fi_GPS); % Save separately.
    C{2}(fi_GPS) = {'99999999999999'}; % Replace with marker
    
    % Do the same for the ASCII (CTD) output
    fi_ascii = find(OPC.Raw.ID == 11); % Find them
    OPC.Raw_ascii = C{2}(fi_ascii); % Save separately.
    C{2}(fi_ascii) = {'99999999999'}; % Replace with marker
    
    % Save the data
    OPC.Raw.Value = str2num(char(C{2}));
    
    % Often the last value in OPC.Raw.ID is a NaN because it picks up the
    % blank line at the end of the file. Check and remove here
    
    if length(OPC.Raw.ID) ~= length(OPC.Raw.Value) & isnan(OPC.Raw.Value(end)==1)
        OPC.Raw.ID = OPC.Raw.ID(1:end-1,:);
    end
    
end


%% Extract Raw Data to meaningful variables %%
OPC.timestep = 0.5; % default timestep (sec)
aa = 0;

% Preallocate
le = length(find(OPC.Raw.ID == 1));

OPC.DigiTime = ones(le,1).*NaN;
OPC.DigiSize = ones(le,1).*NaN;
OPC.LA = ones(le,1).*NaN;

if ~isempty(find(OPC.Raw.ID==8, 1))
    OPC.Flow.RawCounts = ones(le,1).*NaN;
end

if ~isempty(find(OPC.Raw.ID==5, 1))
    OPC.Depth = ones(le,1).*NaN;
end


counter = OPC.timestep;
fi_cnt = find(OPC.DigiTime==counter);
GPS_counter = 0;
CTD_counter = 0;


% OPC.Flow

for ss = 1:length(OPC.Raw.ID)
    if OPC.Raw.ID(ss,1) == 1
        aa = aa + 1;
        OPC.DigiTime(aa,1) = counter; % Same time for all sizes until next data chunk
        OPC.DigiSize(aa,1) = OPC.Raw.Value(ss,1); % Grab Digital Counts of size
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 2 % Light Attenuation
        % Add Light Attenuation to all current time
        OPC.Raw.ID2(fi_cnt,1) = OPC.Raw.Value(ss,1);
        OPC.LA(fi_cnt,1) = OPC.Raw.Value(ss,1);
        %find(OPC.DigiTime==counter)
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 5 % Depth
        % Add Depth to all current time
        OPC.Raw.ID5(fi_cnt,1) = OPC.Raw.Value(ss,1);
        OPC.Depth(fi_cnt,1) = OPC.Raw.Value(ss,1);
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 8 % Flow
        % Add Flow to all current time
        OPC.Raw.ID8(fi_cnt,1) = OPC.Raw.Value(ss,1);
        OPC.Flow.RawCounts(fi_cnt,1) = OPC.Raw.Value(ss,1);
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 9 % Flow2 --> HopcroftData
        OPC.Raw.ID9(fi_cnt,1) = OPC.Raw.Value(ss,1);
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 10 % Flow3 or Roll --> HopcroftData
        OPC.Raw.ID10(fi_cnt,1) = OPC.Raw.Value(ss,1);
    
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 11 & strcmp(file(end-2),'T')==1 % CTD
        
        % Do CTD Data
        CTD_counter = CTD_counter + 1;
        OPC.CTD.Hex((OPC.DigiTime>counter-1 & OPC.DigiTime<=counter),:) = OPC.Raw_ascii(CTD_counter);
        %Even up the size of the vectors outside this loop
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 12 % Flow --> HopcroftData
        OPC.Raw.ID12(fi_cnt,1) = OPC.Raw.Value(ss,1);
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 13 % Flow --> HopcroftData
        OPC.Raw.ID13(fi_cnt,1) = OPC.Raw.Value(ss,1);
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 14  % GPS
        % Add GPS to all current time
        
        GPS_counter = GPS_counter+1;
        
        
        %         if strcmp(file(end-2),'T')==1
        %
        
        com = strfind((OPC.Raw_GPS{GPS_counter}),','); % If there is a comma, there is likely a time print as well
        if ~isempty(com)
            OPC.Raw_GPS(GPS_counter) = {OPC.Raw_GPS{GPS_counter}(com+1:end)};
        end
        
        
        sf = strfind((OPC.Raw_GPS{GPS_counter}),' '); % Find Space in the middle of the GPS
        
        
        if isempty(sf) || length(OPC.Raw_GPS{GPS_counter})<10 || ...
                sum(isstrprop(OPC.Raw_GPS{GPS_counter},'cntrl')) > 1
            
            disp(['GPS Data incorrect (',OPC.Raw_GPS{GPS_counter},' - Ignoring'])
            OPC.GPS.Lon(fi_cnt,1) = NaN;
            OPC.GPS.Lat(fi_cnt,1) = NaN;
            
        else % process as normal
            lat = str2double(char(OPC.Raw_GPS{GPS_counter}(1:2))) + str2double(char(OPC.Raw_GPS{GPS_counter}(3:sf-2)))/60;
            if strcmp(OPC.Raw_GPS{GPS_counter}(sf-1),'S') == 1
                lat = -lat;
            end
            
            OPC.GPS.Lat(fi_cnt,1) = lat;
            
            lon = str2double(char(OPC.Raw_GPS{GPS_counter}(sf+1:sf+3))) + str2double(char(OPC.Raw_GPS{GPS_counter}(sf+4:end-1)))/60;
            if strcmp(OPC.Raw_GPS{GPS_counter}(end),'W') == 1
                lon = -lon;
            end
            OPC.GPS.Lon(fi_cnt,1) = lon;
            
        end
        
        
    elseif aa > 0 && OPC.Raw.ID(ss,1) == 3 % Time
        % Time - add timestep
        fi_cnt = find(OPC.DigiTime==counter);
        
        counter = counter + OPC.timestep;
        
        
    end
end



%% Do some QC


% First check that there aren't any Raw IDs with only a few values. These
% are likely derived from corrupt data.
bin = 0.5:14.5;
C = hist(OPC.Raw.ID,bin);

for i = 1:length(C)-1   
    if C(i) > 0 && C(i) < 10
        if isfield(OPC.Raw,['ID',num2str(ceil(bin(i))).''])==1
            eval(['OPC.Raw = rmfield(OPC.Raw,''ID',num2str(ceil(bin(i))),''');'])
        end
    end
end



% then remove the Depth field
if isfield(OPC,'Depth') == 0
    OPC.Depth = [];
    %    OPC = rmfield(OPC,'Depth');
end

% Then check the lengths of all fields

% OPC logs light and flow at the end of every timestep. Need to extrapolate
% the last flow/LA to the final few counts.
try
    if length(OPC.DigiTime) > length(OPC.Flow.RawCounts)
        OPC.Flow.RawCounts = [OPC.Flow.RawCounts; repmat(OPC.Flow.RawCounts(end), length(OPC.DigiTime)-length(OPC.Flow.RawCounts),1)];
    end
end


try
    if length(OPC.DigiTime) > length(OPC.Raw.ID2)
        OPC.Raw.ID2 = [OPC.Raw.ID2; repmat(OPC.Raw.ID2(end), length(OPC.DigiTime)-length(OPC.Raw.ID2),1)];
    end
end


try
    if length(OPC.DigiTime) > length(OPC.Raw.ID5)
        OPC.Raw.ID5 = [OPC.Raw.ID5; repmat(OPC.Raw.ID5(end), length(OPC.DigiTime)-length(OPC.Raw.ID5),1)];
    end
end


try
    if length(OPC.DigiTime) > length(OPC.Raw.ID8)
        OPC.Raw.ID8 = [OPC.Raw.ID8; repmat(OPC.Raw.ID8(end), length(OPC.DigiTime)-length(OPC.Raw.ID8),1)];
    end
end


try
    if length(OPC.DigiTime) > length(OPC.Raw.ID9)
        OPC.Raw.ID9 = [OPC.Raw.ID9; repmat(OPC.Raw.ID9(end), length(OPC.DigiTime)-length(OPC.Raw.ID9),1)];
    end
end

try
    if length(OPC.DigiTime) > length(OPC.Raw.ID10)
        OPC.Raw.ID10 = [OPC.Raw.ID10; repmat(OPC.Raw.ID10(end), length(OPC.DigiTime)-length(OPC.Raw.ID10),1)];
    end
end

try
    if length(OPC.DigiTime) > length(OPC.Raw.ID12)
        OPC.Raw.ID12 = [OPC.Raw.ID12; repmat(OPC.Raw.ID12(end), length(OPC.DigiTime)-length(OPC.Raw.ID12),1)];
    end
end


try
    if length(OPC.DigiTime) > length(OPC.Raw.ID13)
        OPC.Raw.ID13 = [OPC.Raw.ID13; repmat(OPC.Raw.ID13(end), length(OPC.DigiTime)-length(OPC.Raw.ID13),1)];
    end
end


if length(OPC.DigiTime) > length(OPC.LA)
    OPC.LA = [OPC.LA; repmat(OPC.LA(end), length(OPC.DigiTime)-length(OPC.LA),1)];
end

try
    if length(OPC.DigiTime) > length(OPC.Depth)
        OPC.Depth = [OPC.Depth; repmat(OPC.Depth(end), length(OPC.DigiTime)-length(OPC.Depth),1)];
    end
end

try
    if length(OPC.DigiTime) > length(OPC.CTD.Depth)
        OPC.CTD.Depth = [OPC.CTD.Depth; repmat(OPC.CTD.Depth(end), length(OPC.DigiTime)-length(OPC.CTD.Depth),1)];
    end
end

try
    if length(OPC.DigiTime) > length(OPC.CTD.Hex)
        OPC.CTD.Hex = [OPC.CTD.Hex; repmat(OPC.CTD.Hex(end), length(OPC.DigiTime)-length(OPC.CTD.Hex),1)];
    end
end

try
    if length(OPC.DigiTime) > length(OPC.GPS.Lat)
        OPC.GPS.Lat = [OPC.GPS.Lat; repmat(OPC.GPS.Lat(end), length(OPC.DigiTime)-length(OPC.GPS.Lat),1)];
    end
    
    if length(OPC.DigiTime) > length(OPC.GPS.Lon)
        OPC.GPS.Lon = [OPC.GPS.Lon; repmat(OPC.GPS.Lon(end), length(OPC.DigiTime)-length(OPC.GPS.Lon),1)];
    end
end


% First I need to find the unique time values, then interp the lat/lon
if isfield(OPC,'GPS') == 1
    if OPC.GPS.Lat(1) == 0
        OPC.GPS.Lat(1) = OPC.GPS.Lat(find(OPC.GPS.Lat~=0,1,'first'));
        OPC.GPS.Lon(1) = OPC.GPS.Lon(find(OPC.GPS.Lon~=0,1,'first'));
    end
    
    if OPC.GPS.Lat(end) == 0
        OPC.GPS.Lat(end) = OPC.GPS.Lat(find(OPC.GPS.Lat~=0,1,'last'));
        OPC.GPS.Lon(end) = OPC.GPS.Lon(find(OPC.GPS.Lon~=0,1,'last'));
    end
    
    [uni, ix] = unique(OPC.DigiTime,'stable');
    
    fi_lat = find(OPC.GPS.Lat(ix)~=0); fi_lat0 = find(OPC.GPS.Lat(ix)==0);
    OPC.GPS.Lat(ix(fi_lat0)) = interp1(OPC.DigiTime(ix(fi_lat)),OPC.GPS.Lat(ix(fi_lat)),OPC.DigiTime(ix(fi_lat0)));
    
    fi_lon = find(OPC.GPS.Lon(ix)~=0); fi_lon0 = find(OPC.GPS.Lon(ix)==0);
    OPC.GPS.Lon(ix(fi_lon0)) = interp1(OPC.DigiTime(ix(fi_lon)),OPC.GPS.Lon(ix(fi_lon)),OPC.DigiTime(ix(fi_lon0)));
    
    clear fi_lat* fi_lon*
    
    % Then use the nearest to give the other points the same values
    
    OPC.GPS.Lat(OPC.GPS.Lat==0) = NaN;
    OPC.GPS.Lon(OPC.GPS.Lon==0) = NaN;
    
    for i = 1:length(uni)
        OPC.GPS.Lat(OPC.DigiTime==uni(i)) = mean(OPC.GPS.Lat(OPC.DigiTime==uni(i)),'omitnan');
        OPC.GPS.Lon(OPC.DigiTime==uni(i)) = mean(OPC.GPS.Lon(OPC.DigiTime==uni(i)),'omitnan');
    end
end

