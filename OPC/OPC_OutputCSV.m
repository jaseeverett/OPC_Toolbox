function OPC_OutputCSV(OPC,file)

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
    if ~exist([OPC.Path,'Processed'],'dir')
        mkdir([OPC.Path,'Processed'])
    end
    try
        file = [OPC.Path,'Processed',filesep,OPC.File(1:end-4),'_Output'];
    catch
        file = [pwd,filesep,'Processed',filesep,'_Output'];
    end
end


fid = fopen([file,'.csv'],'w');


fprintf(fid,'%s,','FileName:');
fprintf(fid,'%s\n',OPC.FileName);

% fprintf(fid,'%s,','Unit:');
% fprintf(fid,'%s\n',OPC.Unit);

% fprintf(fid,'%s,','Sampling Date:');
% fprintf(fid,'%s\n',OPC.Sampling_date);

% fprintf(fid,'%s,','Processing Date:');
% fprintf(fid,'%s\n',OPC.Date_Extracted);

fprintf(fid,'%s,','Volume (m3):');
fprintf(fid,'%g\n',OPC.Flow.TotalVol);

fprintf(fid,'%s,','MinESD (um):');
fprintf(fid,'%g\n',OPC.MinESD*1e6);

fprintf(fid,'%s,','MaxESD (um):');
fprintf(fid,'%g\n\n',OPC.MaxESD*1e6);

fprintf(fid,'%s\n\n','The following analysis is completed using the UNSW-OPC software. The full dataset is stored below for further analysis');

fprintf(fid,'%s\n\n','Statistics');
fprintf(fid,'%s,','Pareto Slope:');
fprintf(fid,'%f\n',OPC.Pareto.Slope);
fprintf(fid,'%s,','NBSS Linear Slope:');
fprintf(fid,'%f\n',OPC.NBSS.Lin.Slope);
fprintf(fid,'%s,','NBSS Linear Intercept:');
fprintf(fid,'%f\n',OPC.NBSS.Lin.Intercept);
fprintf(fid,'%s,','NBSS Linear r2:');
fprintf(fid,'%f\n\n',OPC.NBSS.Lin.r2);

fprintf(fid,'%s,','NBSS Non-Linear Curvature:');
fprintf(fid,'%f\n',OPC.NBSS.NLin.Curve);
fprintf(fid,'%s,','NBSS Non-Linear X-Vertex:');
fprintf(fid,'%f\n',OPC.NBSS.NLin.XVertex);
fprintf(fid,'%s,','NBSS Non-Linear Y-Vertex:');
fprintf(fid,'%f\n',OPC.NBSS.NLin.YVertex);
fprintf(fid,'%s,','NBSS Non-Linear r2:');
fprintf(fid,'%f\n',OPC.NBSS.Lin.r2);

fprintf(fid,'%s,','Number of particles used for NBSS Analysis:');
fprintf(fid,'%f\n\n',sum(OPC.NBSS.Binned_ESD(:,2)));

fprintf(fid,'\n\n%s\n\n','Normalised Biomass');
fprintf(fid,'%s,','Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_Biomass)),'\n'],OPC.NBSS.Binned_Biomass(:,1)');
fprintf(fid,'%s,','Min Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_Biomass)),'\n'],OPC.NBSS.Binned_Biomass(:,3)');
fprintf(fid,'%s,','Max Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_Biomass)),'\n'],OPC.NBSS.Binned_Biomass(:,4)');
fprintf(fid,'%s,','Binned Biomass (mg m-3)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_Biomass)),'\n'],(OPC.NBSS.Binned_Biomass(:,2).*OPC.NBSS.Binned_Biomass(:,1))');
fprintf(fid,'%s,','Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.NBSS)),'\n'],OPC.NBSS.NBSS');


fprintf(fid,'\n\n%s\n\n','Log10 Normalised Biomass');
fprintf(fid,'%s,','log10 Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_Biomass)),'\n'],log10(OPC.NBSS.Binned_Biomass(:,1))');
fprintf(fid,'%s,','log10 Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.NBSS)),'\n'],log10(OPC.NBSS.NBSS)');


fprintf(fid,'\n\n%s\n\n','Equivalent Spherical Diameter (ESD)');
fprintf(fid,'%s,','Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_ESD)),'\n'],OPC.NBSS.Binned_ESD(:,1).*1e6');
fprintf(fid,'%s,','Min Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_ESD)),'\n'],OPC.NBSS.Binned_ESD(:,3).*1e6');
fprintf(fid,'%s,','Max Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_ESD)),'\n'],OPC.NBSS.Binned_ESD(:,4).*1e6');
fprintf(fid,'%s,','Total Counts');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.Binned_ESD)),'\n'],OPC.NBSS.Binned_ESD(:,2)');


fprintf(fid,'\n\n\n%s\n\n','The full dataset is available here for further analysis');
fprintf(fid,'\n%s\n\n','Normalised Biomass');
fprintf(fid,'%s,','Nominal Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_Biomass)),'\n'],OPC.NBSS.all.Binned_Biomass(:,1)');
fprintf(fid,'%s,','Min Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_Biomass)),'\n'],OPC.NBSS.all.Binned_Biomass(:,3)');
fprintf(fid,'%s,','Max Bin Size (mg)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_Biomass)),'\n'],OPC.NBSS.all.Binned_Biomass(:,4)');
fprintf(fid,'%s,','Binned Biomass (mg m-3)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_Biomass)),'\n'],(OPC.NBSS.all.Binned_Biomass(:,2).*OPC.NBSS.all.Binned_Biomass(:,1))');
fprintf(fid,'%s,','Normalised Biomass (m-3)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.NBSS)),'\n'],OPC.NBSS.all.NBSS');



fprintf(fid,'\n\n%s\n\n','Equivalent Spherical Diameter (ESD)');
fprintf(fid,'%s,','Nominal Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_ESD)),'\n'],OPC.NBSS.all.Binned_ESD(:,1).*1e6');
fprintf(fid,'%s,','Min Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_ESD)),'\n'],OPC.NBSS.all.Binned_ESD(:,3).*1e6');
fprintf(fid,'%s,','Max Bin Size (um)');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_ESD)),'\n'],OPC.NBSS.all.Binned_ESD(:,4).*1e6');
fprintf(fid,'%s,','Total Counts');
fprintf(fid,[repmat('%f,',1,length(OPC.NBSS.all.Binned_ESD)),'\n'],OPC.NBSS.all.Binned_ESD(:,2)');


if isfield(OPC,'DepthBins') == 1
    fprintf(fid,'\n\n\n%s\n','Depth Binned Data - 1 m resolution');
    fprintf(fid,'\n%s\n\n','Equivalent Spherical Diameter (ESD)');
    
    fprintf(fid,',%s,','Nominal Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(OPC.DepthBins.Bins)),'\n'],OPC.DepthBins.Bins.*1e6');
    fprintf(fid,',%s,','Min Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(OPC.DepthBins.Bins)),'\n'],OPC.DepthBins.Limits(1:end-1).*1e6');
    fprintf(fid,',%s,','Max Bin Size (um)');
    fprintf(fid,[repmat('%f,',1,length(OPC.DepthBins.Bins)),'\n'],OPC.DepthBins.Limits(2:end).*1e6');
    
    
    fprintf(fid,'\n%s,','Depth Bin (m)');
    fprintf(fid,'%s,','Volume (m3)');
    fprintf(fid,'%s\n','Bug Counts ----->');
    
    for a = 1:length(OPC.DepthBins.Depth)
        fprintf(fid,'%s,',[num2str(OPC.DepthBins.Depth(a)-1),' - ',num2str(OPC.DepthBins.Depth(a)),' m']);
        fprintf(fid,'%f,',OPC.DepthBins.Vol(a));
        fprintf(fid,[repmat('%f,',1,length(OPC.DepthBins.Binned_ESD)),'\n'],[ OPC.DepthBins.Binned_ESD(a,:)]);
    end
    
end



fclose(fid);