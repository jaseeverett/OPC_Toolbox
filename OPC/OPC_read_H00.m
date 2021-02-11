function OPC = OPC_read_H00(file,MinESD,MaxESD,flow_mark,vol)

% Useage: OPC = OPC_read_H00(file)
% Jason Everett (UNSW)
% Written October 2016

if nargin ~= 7
    out = 1;
end


% Load data
fid = fopen(file,'r');
data = textscan(fid,'%s');
data = (char(data{1}));
fclose(fid);
clear fid


OPC.FileName = file;
OPC.Processed_Date = datestr(now);
OPC.Processed_By = 'Jason Everett (UNSW)';
OPC.Processed_Script = mfilename;

OPC.H00_date = ['',strtrim(data(3,:)),'-', strtrim(data(2,:)),'-',strtrim(data(5,:)),' ',strtrim(data(4,:)),''];

%% Save at text file
fid = fopen([file(1:end-3) 't00'],'w');

for i = 1:length(data)
    fprintf(fid,'%s\n',strtrim(data(i,:)));
end
fclose(fid);


OPC.mat = str2num(strtrim(data(6:end,:)));

OPC.mat(:,2) = OPC.mat(:,2)./1e6;

Binned_Counts = OPC.mat(:,3); % Get all counts
OPC.ESD = ones(sum(Binned_Counts),1).*NaN;

% s = start, e = end
s = 1;

fi = find(Binned_Counts>0);

for a = 1:length(fi)
    e = s + Binned_Counts(fi(a)) - 1;
    OPC.ESD(s:e,1) = repmat(OPC.mat(fi(a),2),Binned_Counts(fi(a)),1);
    s = e + 1;
end

OPC.MinESD = MinESD;
OPC.MaxESD = MaxESD;
OPC.NBSS.min_count = 1;
OPC.Unit = 'OPC1T';
OPC.Flow.flow_mark = flow_mark;

OPC = OPC_SurfaceArea(OPC);

if flow_mark ~= 3
    %% Calculate Volume %%
    % OPC-2T aperture is 10 cm x 2 cm
    OPC.Flow.Vol = OPC.SA.*OPC.Flow.Flow; % (m3/s)
    OPC.Flow.TotalVol = sum(OPC.Flow.Vol,,'omitnan');
    OPC.Flow.FlowUsed = 'Flowmeter';
elseif flow_mark == 3
    OPC.Flow.Vol = vol;
    OPC.Flow.TotalVol = vol;
    OPC.Flow.FlowUsed = 'RecordedVolume';
end

% Load OPC Paramters
OPC = OPC_Parameters(OPC);

%% Calculate Pareto
OPC = OPC_Pareto(OPC);

%% Bin the data
OPC = OPC_Bin(OPC);

OPC = OPC_NBSS(OPC);


