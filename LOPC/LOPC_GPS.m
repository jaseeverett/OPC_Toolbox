function LOPC = LOPC_GPS(LOPC,data)

% Load CTD data
%
% CTD data doesn't seem to be logged every timestep. It appears to be every
% 2-3 timepts. Therefore we need to interporlate this data onto the SMEP
% datastream. We do this by finding the closest L5 values, using their
% time, to infer a CTD time. Then I interp the CTD data onto the SMEP time.
%

en = strfind(data,'$GPGGA,');
ix = ~cellfun('isempty',en)==1;


if sum(ix)~=0
    
    temp = data(ix); %temp char
    
    % Correct for any known errors in .dat files
    temp = strrep(temp,'C $GPGGA,','$GPGGA,');
    
    LOPC.GPS.Lat = ones(length(temp),1).*NaN;
    LOPC.GPS.Lon = LOPC.GPS.Lat;
    LOPC.GPS.datenum = LOPC.GPS.Lat;
    LOPC.GPS.datenum2 = LOPC.GPS.Lat;
    
    %% The GPS is always in UTC yet the LOPC time may not be. So I don't
    % have to mess around with figuring this out, I am just finding the
    % closest LOPC time to each GPS reading and inserting it in the correct
    % place.
    
    ixGPS = find(~cellfun('isempty',en)==1);
    % Find the index of all SEPs
    s = strfind(data,'L5');
    ixSEP = find(~cellfun('isempty',s)==1);
    ixSEP = ixSEP(1:end,1); % Remove the last L5 to ensure the interp below isn't outside the time limits
    
    % Find closest SEP to each GPS in order to get the approx time
    ind = interp1(ixSEP, 1:length(ixSEP), ixGPS, 'nearest','extrap');
    LOPC.GPS.datenum = LOPC.datenum(ind);
    
    %%
    for a = 1:length(temp)
        [GPSdata,ierr]  =  LOPC_nmealineread(temp{a});
        
        if ierr == 0
            LOPC.GPS.Lat(a,1) = GPSdata.latitude;
            LOPC.GPS.Lon(a,1) = GPSdata.longitude;
            LOPC.GPS.datenum2(a,1) = GPSdata.GPS_datenum;
        else
            LOPC.GPS.Lat(a,1) = NaN;
            LOPC.GPS.Lon(a,1) = NaN;
            LOPC.GPS.datenum2(a,1) = NaN;
        end
    end
    
    
    fi_bad = find(isnan(LOPC.GPS.Lat)==1);
    if ~isempty(fi_bad)
        fi_good = find(isnan(LOPC.GPS.Lat)==0);
        LOPC.GPS.Lat(fi_bad) = interp1(LOPC.GPS.datenum2(fi_good),LOPC.GPS.Lat(fi_good),LOPC.GPS.datenum2(fi_bad),'linear','extrap');
        LOPC.GPS.Lon(fi_bad) = interp1(LOPC.GPS.datenum2(fi_good),LOPC.GPS.Lon(fi_good),LOPC.GPS.datenum2(fi_bad),'linear','extrap');
        disp(['Replacing ',num2str(length(fi_bad)),' Lat/Lon points with interp'])
    end
    
    % temporarily insert a lat reading for CTD
    LOPC.Lat = LOPC.GPS.Lat(find(isnan(LOPC.GPS.Lat)==0,1,'first'));
    
    %% Interpolate GPS data onto the same resolution as the particles
    
    fi = find(diff(LOPC.GPS.datenum)==0);
    while ~isempty(fi)
        LOPC.GPS.datenum(fi+1) = LOPC.GPS.datenum(fi+1) + 0.1/86400; % Add 1/10 sec to identical values
            fi = find(diff(LOPC.GPS.datenum)==0);
    end
    
    disp('Rough interpolation of Lat/Lon onto particle resolution')
    Lat_new = interp1(LOPC.GPS.datenum, LOPC.GPS.Lat, LOPC.datenum);
    Lon_new = interp1(LOPC.GPS.datenum, LOPC.GPS.Lon, LOPC.datenum);
    
    LOPC.GPS.Lat = Lat_new; clear Lat_new
    LOPC.GPS.Lon = Lon_new; clear Lon_new
    
    
else
    disp('No GPS data stream found within .dat file')
    disp('')
end






% $GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47
%
% Where:
%      GGA          Global Positioning System Fix Data
%      123519       Fix taken at 12:35:19 UTC
%      4807.038,N   Latitude 48 deg 07.038' N
%      01131.000,E  Longitude 11 deg 31.000' E
%      1            Fix quality: 0 = invalid
%                                1 = GPS fix (SPS)
%                                2 = DGPS fix
%                                3 = PPS fix
% 			       4 = Real Time Kinematic
% 			       5 = Float RTK
%                                6 = estimated (dead reckoning) (2.3 feature)
% 			       7 = Manual input mode
% 			       8 = Simulation mode
%      08           Number of satellites being tracked
%      0.9          Horizontal dilution of position
%      545.4,M      Altitude, Meters, above mean sea level
%      46.9,M       Height of geoid (mean sea level) above WGS84
%                       ellipsoid
%      (empty field) time in seconds since last DGPS update
%      (empty field) DGPS station ID number
%      *47          the checksum data, always begins with *




function [data,ierr]  =  LOPC_nmealineread(nline)
%NMEALINEREAD reads an NMEA sentence into a MATLAB structure array
%
%  DATA  =  NMEALINEREAD(NLINE)
%  [DATA,IERR]  =  NMEALINEREAD(NLINE)
%
%  NLINE is an NMEA sentence. DATA is a MATLAB structure array with a
%  varying format, detailed below.
%
%  NMEALINEREAD currently supports the following NMEA sentences:
%                   $GPGGA  Global positioning system fixed data
%                   $GPGLL  Geographic poition [latitude, longitude & time]
%                   $GPVTG  Course over ground and ground speed
%                   $GPZDA  UTC date / time and local time zone offset
%                   $SDDBS  Echo sounder data
%
%  $GPGGA gives a DATA structure with the following fields:
%       Time        Day fraction
%       latitude    Decimal latitude north
%       longitude   Decimal longitude east
%
%  $GPGLL gives a DATA structure with the following fields:
%       Time    Day fraction
%       latitude    Decimal latitude north
%       longitude   Decimal longitude east
%
%  $GPVTG gives a DATA structure with the following fields:
%       speed       Speed over ground in knots
%       truecourse  Course over ground in degrees true
%
%  $GPZDA gives a DATA structure with the following fields:
%       Time    Day number
%       offset      The offset (as a fraction of a day) needed to
%                   generate the local time from BODCTime
%
%  $SDDBS gives a DATA structure with the following field:
%       depth       Depth of water below surface (m)
%
%
%  IERR returns an error code:
%       -2  -  NMEA string recognised, but function not yet able to read
%              this string
%       -1  -  NMEA string not recognised
%       0   -  No errors

% Adam Leadbetter (alead@bodc.ac.uk) -      2006-Oct-24
% Lex Lombardi (llombardi@dspaceinc.com) -  2014-Feb-19
%                       partially updated to use textscan() for parsing
%                       added support for other fields in GPGGA
%                       added checksum calculator

ierr  =  0;

%
%%  Set up a list of valid NMEA strings
%
nmea_options  =  [  '$GPGGA'
    '$GPGLL'
    '$GPGSA'
    '$GPGSV'
    '$GPRMC'
    '$GPVTG'
    '$GPZDA'
    '$SDDBS'];
%
%%  Find which string we're dealing with

fields = textscan(nline,'%s','delimiter',',');

if length(fields{:}) < 15
    % There is no checksum in this one. Just ignore and hope for the best
    % Or use field 7 to confirm a 1 or 2 (GPS fix). 0 indicates no good fix
%     disp('No checksum')
    no_check = 1;
    fields{1}{15} = 'NaN';
    
else
    % Jason Everett - modify for LOPC - often checksum is garbled. If so, this
    % line errors (June 21 2016)
    try
        %pull the checksum out of the last field and make a new one for it
        fields{1}{end+1} = fields{1}{end}(end-1:end);
    catch
        %checksum is bad!
        fprintf(1,'\n\tWarning: Checksum Corrupted  - %s ~= %s',char(fields{1}(end)),'\n');
        data  =  NaN;
        ierr  =  -1;
        return
    end
end
%cut off the old last field at the chksum delimiter
fields{1}(end-1) = strtok(fields{1}(end-1), '*');
case_t = find(strcmp(fields{1}(1), nmea_options),1);

try
    fields = char(fields{1});
catch
    not_char = 1; % If all fields won't convert, there is likely an error
end
%%  If no valid NMEA string found - quit with an error


if isempty(case_t) | exist('not_char','var')
    fprintf(1,'\n\tWarning: Not a valid NMEA string  -  %s ...\n',nline);
    data  =  NaN;
    ierr  =  -1;
    return
end


%
%% read and check the checksum
if ~exist('no_check','var')
    % Initialise checksum
    checksum = uint8(0);
    
    %calc it - we drop the leading '$' and trim off the '*' and anything past it
    for i_char = 2:(find(nline=='*',1,'last')-1)
        checksum = bitxor(checksum, uint8(nline(i_char)));
    end
    checksum = dec2hex(checksum, 2);
    
    %check it
    if ((strcmp(fields(end,1:2),checksum))==0)
        %checksum is bad!
        fprintf(1,'\n\tWarning: Checksum Bad  - %s ~= %s',fields(end),checksum,'\n');
        data  =  NaN;
        ierr  =  -1;
        return
    end
end

%% TURN ON THE SWITCH!

switch case_t
    case 1 %% GPGGA Read global positioning system fixed data
        
        %first data field is the time
        t_time  =  fields(2,1:end);
        if(isempty(t_time))
            data.GPS_datenum  =  NaN;
        else
            data.GPS_datenum  =  datenum(t_time,'HHMMSS') - ...
                floor(datenum(t_time,'HHMMSS'));
        end
        clear t_time;
        
        %next data field is the lat
        t_lat  =  fields(3,1:end);
        data.latitude  =  ...
            str2double(t_lat(1:2)) + (str2double(t_lat(3:end))/60);
        t_latDir = fields(4);
        if(t_latDir  ==  'S')
            data.latitude  =  data.latitude  *  -1;
        end
        clear t_lat t_latDir;
        
        %then the lon
        t_lon  = fields(5,1:end);
        data.longitude  =  ...
            str2double(t_lon(1:3)) + (str2double(t_lon(4:end))/60);
        t_lonDir = fields(6);
        if(t_lonDir  ==  'W')
            data.longitude  =  data.longitude  *  -1;
        end
        clear t_lon t_longDir;
        
        %Get the fix quality where 0 = none, 1 = GPS fix, 2 = DGPS fix
        t_fix = fields(7,1:end);
        data.fix  = str2double(t_fix);
        clear t_fix;
        
        %read the number of satellites
        t_sat = fields(8,1:end);
        data.satellites = str2double(t_sat);
        clear t_sat;
        
        %read HDOP
        t_HDOP= fields(9,1:end);
        if isempty(t_HDOP)
            %do nothing
        else
            data.HDOP = str2double(t_HDOP);
        end
        clear t_HDOP;
        
        %Read Altitude
        t_alt = fields(10,1:end);
        if isempty(t_alt)
            %do nothing
        else
            data.altitude = str2double(t_alt);
        end
        clear t_alt;
        
        t_altUnit = fields(11,1:end);
        if (t_altUnit(1)=='M')
            %do nothing
        else
            fprintf(1,'\tWarning: unknown Altitude Unit - %s\n', t_altUnit);
        end
        clear t_altUnit;
        
        % Height of geoid.... meh
        t_altGeo = fields(12,1:end);
        clear t_altGeo;
        t_altGeoUnit = fields(13,1:end);
        if (t_altGeoUnit(1)=='M')
            %do nothing
        else
            fprintf(1,'\tWarning: unknown Height over WGS84 Unit - %s\n', t_altGeoUnit);
        end
        clear t_altGeoUnit;
        
        %Time since DGPS update
        t_DGPSupdate = fields(14,1:end);
        
        
        %Checksum
        
        t_chkSum = fields(15,1:end);
        
        
        
        
        
    case 2 %% GPGLL Read geographic position [lat/lon] and time
        
        t_lat  = fields(2,1:end);
        data.latitude  =  str2double(t_lat(1:2)) + ...
            (str2double(t_lat(3:end)) / 60);
        t_latDir  =  fields(3,1:end);
        if(t_latDir  ==  'S')
            data.latitude  =  data.latitude * -1;
        end
        clear t_lat t_latDir
        
        t_lon  =  fields(4,1:end);
        data.longitude  =  str2double(t_lon(1:3)) + ...
            (str2double(t_lon(4:end)) / 60);
        t_lonDir = fields(5,1:end);
        if(t_lonDir  ==  'W')
            data.longitude  =  data.longitude  *  -1;
        end
        
        if(length(fields) == 7)
            t_time  =  fields(6,1:end);
            data.BODCTime  =  datenum(t_time,'HHMMSS') - ...
                floor(datenum(t_time,'HHMMSS'));
        else
            data.BODCTime  =  NaN;
        end
        
    case 3 %% GPGSA: Read Procision and fix quality information
        %fix and mode info in fields 2&3
        
        t_mode = fields(2,1:end);
        switch t_mode(1)
            case 'M'
                data.fixmode='Manual';
            case 'A'
                data.fixmode='Automatic';
            otherwise
                data.fixmode=NaN;
        end
        clear t_mode
        
        t_mode = fields(3,1:end);
        switch t_mode(1)
            case '1'
                data.fixtype=1; %no fix
                data.fix=0;
            case '2'
                data.fixtype=2; %2D fix
                data.fix=0;
            case '3'
                data.fixmode=3; %3D fix
                data.fix=0;
            otherwise
                data.fixmode=NaN;
        end
        clear t_mode
        
        %% satalite id's in fields 4-15
        t_satID=str2num(fields(4:15,1:end));
        if not(isempty(t_satID))
            data.satellites=t_satID;
        else
            data.satellites=NaN;
        end
        
        %% Dilution of precision's
        t_PDOP = fields(16,1:end);
        if not(isempty(t_PDOP))
            data.PDOP=str2double(t_PDOP);
        else
            data.PDOP=NaN;
        end
        
        t_HDOP = fields(17,1:end);
        if not(isempty(t_PDOP))
            data.HDOP=str2double(t_HDOP);
        else
            data.HDOP=NaN;
        end
        
        t_VDOP = fields(18,1:end);
        if not(isempty(t_VDOP))
            data.VDOP=str2double(t_VDOP);
        else
            data.VDOP=NaN;
        end
        clear t_PDOP t_HDOP t_VDOP
        
        
    case 6 %% GPVTG: Read course over ground and ground speed
        
        t_course  =  fields(2,1:end);
        if(isempty(t_course))
            data.truecourse  =  NaN;
        else
            data.truecourse  =  str2double(t_course);
        end
        
        t_course  =  fields(4,1:end);
        if(isempty(t_course))
            data.magneticcourse  =  NaN;
        else
            data.magneticcourse  =  str2double(t_course);
        end
        
        t_gspeed  =  fields(6,1:end);
        if(isempty(t_gspeed))
            data.groundspeed.knot  =  NaN;
        else
            data.groundspeed.knot  =  str2double(t_gspeed);
        end
        
        t_gspeed  =  fields(6,1:end);
        if(isempty(t_gspeed))
            data.groundspeed.kph  =  NaN;
        else
            data.groundspeed.kph  =  str2double(t_gspeed);
        end
        
        clear t_course t_gspeed;
        
    case 7 %%  Read UTC Date / Time and Local Time Zone Offset
        
        data.BODCTime  =  (datenum(nline(11:20),'dd,mm,yyyy') + ...
            (datenum(nline(1:6),'HHMMSS') - ...
            floor(datenum(nline(1:6),'HHMMSS'))));
        data.offset  =  (str2double(nline(22:23)) + ...
            (str2double(nline(25:26)) / 60)) / 24;
    case 8 %%  Read echo sounder data
        
        com_mask  =  strfind(nline,',');
        data.depth  =  str2double(...
            nline(com_mask(2) + 1: com_mask(3)-1));
    otherwise
        data  =  NaN;
        ierr  =  -2;
        fprintf(1,...
            '\n\tWarning: NMEA reader not yet implemented for this string  -  %s  ...\n',...
            nline);
end

%%  Tidy up the output structure
data  =  orderfields(data);
