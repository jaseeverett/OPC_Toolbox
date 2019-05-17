function LOPC_OutputCSV(LOPC,file)

% Exports LOPC data into a .csv file
%
% Useage: LOPC_OutputCSV(LOPC,file)
%   where LOPC is the structure outputted by LOPC_Analyse and
%   file (optional) is the path and filename under which to save the csv.
%
% Written by Jason Everett (UNSW); June 2014
%

if nargin == 1
    % Check if directory exists.
    if ~exist([LOPC.Path,'Processed'],'dir')
        mkdir([LOPC.Path,'Processed'])
    end
    try
        file = [LOPC.Path,'Processed',filesep,LOPC.File(1:end-4),'_Output'];
    catch
        file = [pwd,filesep,'Processed',filesep,'_Output'];
    end
end


fid = fopen([file,'.csv'],'w');


fprintf(fid,'%s,','FileName:');
fprintf(fid,'%s\n',LOPC.FileName);

fprintf(fid,'%s,','Unit:');
fprintf(fid,'%s\n',LOPC.Unit);

fprintf(fid,'%s,','Sampling Date:');
fprintf(fid,'%s\n',LOPC.Sampling_date);

fprintf(fid,'%s,','Processing Date:');
fprintf(fid,'%s\n',LOPC.Date_Extracted);

fprintf(fid,'%s,','Volume (m3):');
try
    fprintf(fid,'%g\n',LOPC.vol);
catch
    fprintf(fid,'%g\n',LOPC.Flow.TotalVol);
    
end
fprintf(fid,'%s,','MinESD (um):');
fprintf(fid,'%g\n',LOPC.MinESD*1e6);

fprintf(fid,'%s,','MaxESD (um):');
fprintf(fid,'%g\n\n',LOPC.MaxESD*1e6);

fprintf(fid,'%s\n\n','The following analysis is completed using the UNSW-LOPC software. The full dataset is stored below for further analysis');

fprintf(fid,'%s\n\n','Statistics');
fprintf(fid,'%s,','Pareto Slope:');
fprintf(fid,'%f\n',LOPC.Pareto.Slope);
fprintf(fid,'%s,','NBSS Linear Slope:');
fprintf(fid,'%f\n',LOPC.NBSS.Lin.Slope);
fprintf(fid,'%s,','NBSS Linear Intercept:');
fprintf(fid,'%f\n',LOPC.NBSS.Lin.Intercept);
fprintf(fid,'%s,','NBSS r2:');
fprintf(fid,'%f\n',LOPC.NBSS.Lin.r2);

fprintf(fid,'%s,','Number of particles used for NBSS Analysis:');
fprintf(fid,'%f\n\n',sum(LOPC.NBSS.Histo));

fprintf(fid,'\n\n%s\n\n','Normalised Biomass');
fprintf(fid,'%s,','Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Binned_Bio)),'\n'],LOPC.NBSS.Bins);
fprintf(fid,'%s,','Min Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Binned_Bio)),'\n'],LOPC.NBSS.Limits(1:end-1));
fprintf(fid,'%s,','Max Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Binned_Bio)),'\n'],LOPC.NBSS.Limits(2:end));
fprintf(fid,'%s,','Binned Biomass (mg m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Binned_Bio)),'\n'],(LOPC.NBSS.Binned_Bio));
fprintf(fid,'%s,','Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.NB)),'\n'],LOPC.NBSS.NB);


fprintf(fid,'\n\n%s\n\n','Log10 Normalised Biomass');
fprintf(fid,'%s,','log10 Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Binned_Bio)),'\n'],log10(LOPC.NBSS.Bins));
fprintf(fid,'%s,','log10 Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.NB)),'\n'],log10(LOPC.NBSS.NB));


fprintf(fid,'\n\n%s\n\n','Equivalent Spherical Diameter (ESD)');
fprintf(fid,'%s,','Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Bins_ESD)),'\n'],LOPC.NBSS.Bins_ESD.*1e6);
fprintf(fid,'%s,','Min Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Bins_ESD)),'\n'],LOPC.NBSS.Limits_ESD(1:end-1).*1e6);
fprintf(fid,'%s,','Max Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Bins_ESD)),'\n'],LOPC.NBSS.Limits_ESD(2:end).*1e6);
fprintf(fid,'%s,','Total Counts');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.Bins_ESD)),'\n'],LOPC.NBSS.Histo);


fprintf(fid,'\n\n\n%s\n\n','The full dataset is available here for further analysis');
fprintf(fid,'\n\n%s\n\n','Normalised Biomass');
fprintf(fid,'%s,','Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Bio)),'\n'],LOPC.NBSS.all.Bins);
fprintf(fid,'%s,','Min Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Bio)),'\n'],LOPC.NBSS.all.Limits(1:end-1));
fprintf(fid,'%s,','Max Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Bio)),'\n'],LOPC.NBSS.all.Limits(2:end));
fprintf(fid,'%s,','Binned Biomass (mg m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Bio)),'\n'],(LOPC.NBSS.all.Binned_Bio));
fprintf(fid,'%s,','Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.NB)),'\n'],LOPC.NBSS.all.NB);


fprintf(fid,'\n\n%s\n\n','Log10 Normalised Biomass');
fprintf(fid,'%s,','log10 Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Bio)),'\n'],log10(LOPC.NBSS.all.Bins));
fprintf(fid,'%s,','log10 Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.NB)),'\n'],log10(LOPC.NBSS.all.NB));


fprintf(fid,'\n\n%s\n\n','Equivalent Spherical Diameter (ESD)');
fprintf(fid,'%s,','Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Bins)),'\n'],LOPC.NBSS.all.Bins_ESD.*1e6);
fprintf(fid,'%s,','Min Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Bins)),'\n'],LOPC.NBSS.all.Limits_ESD(1:end-1).*1e6);
fprintf(fid,'%s,','Max Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Bins)),'\n'],LOPC.NBSS.all.Limits_ESD(2:end).*1e6);
fprintf(fid,'%s,','Total Counts');
fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Bins)),'\n'],LOPC.NBSS.all.Histo);



% fprintf(fid,'\n%s\n\n','Normalised Biomass');
% fprintf(fid,'%s,','Nominal Bin Size (mg)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Biomass)),'\n'],LOPC.NBSS.all.Binned_Biomass(:,1)');
% fprintf(fid,'%s,','Min Bin Size (mg)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Biomass)),'\n'],LOPC.NBSS.all.Binned_Biomass(:,3)');
% fprintf(fid,'%s,','Max Bin Size (mg)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Biomass)),'\n'],LOPC.NBSS.all.Binned_Biomass(:,4)');
% fprintf(fid,'%s,','Binned Biomass (mg m-3)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_Biomass)),'\n'],(LOPC.NBSS.all.Binned_Biomass(:,2).*LOPC.NBSS.all.Binned_Biomass(:,1))');
% fprintf(fid,'%s,','Normalised Biomass (m-3)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.NBSS)),'\n'],LOPC.NBSS.all.NBSS');
% 
% 
% 
% fprintf(fid,'\n\n%s\n\n','Equivalent Spherical Diameter (ESD)');
% fprintf(fid,'%s,','Nominal Bin Size (um)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_ESD)),'\n'],LOPC.NBSS.all.Binned_ESD(:,1).*1e6');
% fprintf(fid,'%s,','Min Bin Size (um)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_ESD)),'\n'],LOPC.NBSS.all.Binned_ESD(:,3).*1e6');
% fprintf(fid,'%s,','Max Bin Size (um)');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_ESD)),'\n'],LOPC.NBSS.all.Binned_ESD(:,4).*1e6');
% fprintf(fid,'%s,','Total Counts');
% fprintf(fid,[repmat('%f,',1,length(LOPC.NBSS.all.Binned_ESD)),'\n'],LOPC.NBSS.all.Binned_ESD(:,2)');


if isfield(LOPC,'DepthBins') == 1
    fprintf(fid,'\n\n\n%s\n','Depth Binned Data - 1 m resolution');
    fprintf(fid,'\n%s\n\n','Equivalent Spherical Diameter (ESD)');
    
    fprintf(fid,',%s,','Nominal Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(LOPC.DepthBins.Bins)),'\n'],LOPC.DepthBins.Bins.*1e6');
    fprintf(fid,',%s,','Min Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(LOPC.DepthBins.Bins)),'\n'],LOPC.DepthBins.Limits(1:end-1).*1e6');
    fprintf(fid,',%s,','Max Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(LOPC.DepthBins.Bins)),'\n'],LOPC.DepthBins.Limits(2:end).*1e6');
    
    
    fprintf(fid,'\n%s,','Depth Bin (m)');
    fprintf(fid,'%s,','Volume (m3)');
    fprintf(fid,'%s\n','Bug Counts ----->');
    
    for a = 1:length(LOPC.DepthBins.Depth)
        fprintf(fid,'%s,',[num2str(LOPC.DepthBins.Depth(a)-1),' - ',num2str(LOPC.DepthBins.Depth(a)),' m']);
        fprintf(fid,'%f,',LOPC.DepthBins.Vol(a));
        fprintf(fid,[repmat('%f,',1,length(LOPC.DepthBins.Binned_ESD)),'\n'],[ LOPC.DepthBins.Binned_ESD(a,:)]);
    end
    
end



fclose(fid);