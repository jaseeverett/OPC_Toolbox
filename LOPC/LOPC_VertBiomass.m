function LOPC = LOPC_VertBiomass(LOPC)

% Calculate Biomass in 5m bin increments from 5 m to max depth
% Assumes 1mg per whatever from Suthers et al

%% Find max depth and round down to the lower 5m increment so there isn't
% a smaller increment ie

maxD = max(LOPC.CTD.Depth);
LOPC.Vert.maxDepth = round2(maxD,5);

LOPC.Vert.Depth_Limits = 5:5:LOPC.Vert.maxDepth;
LOPC.Vert.Depth_Bins = 7.5:5:LOPC.Vert.maxDepth;

for a = 1:length(LOPC.Vert.Depth_Bins)
    
    % Find data in depth range
    fi = find(LOPC.CTD.Depth >= LOPC.Vert.Depth_Limits(a)...
        & LOPC.CTD.Depth < LOPC.Vert.Depth_Limits(a+1));
    
    % Calculate Flow
    if ~isnan(LOPC.Flow.Vol)
        LOPC.Vert.Vol(a,1) = sum(LOPC.Flow.Vol(fi));
    else
        LOPC.Vert.Vol(a,1) = LOPC.Flow.TotalVol./length(LOPC.Vert.Bins);
        disp('Using total volume to calculate vertical vol')
    end
    
    % Create a new LOPC structure called new, and redcue the data to the
    % required depth range.
    new = LOPC;
    new.SMEP = new.SMEP(fi,:);
    
    % Calculte the sizes of each particles with the Pareto script.
    new = LOPC_ParetoCounts(new);
    
    
    %% 2. Reduced NBSS Bins
    % Reduce bins/limits to match MinESD
    LOPC.Vert.Limits = LOPC.NBSS.red.Limits;
    LOPC.Vert.Bins = LOPC.NBSS.red.Bins;
    
    h = histc(new.Pareto.ESDs,new.NBSS.red.Limits)';
    
    % LOPC.NBSS.red.Bins = LOPC.NBSS.Bins; %LOPC.NBSS.all.Bins(fi(end)+1:end);
    % LOPC.NBSS.red.Limits = LOPC.NBSS.Limits; %LOPC.NBSS.all.Limits(fi(end)+1:end);
    LOPC.Vert.Histo(a,:) = [h(1:end-2) h(end)+h(end-1)];    
    LOPC.Vert.Binned_ESD(a,:,:) = [LOPC.NBSS.red.Bins' LOPC.Vert.Histo(a,:)'...
        LOPC.Vert.Limits(1:end-1)' LOPC.Vert.Limits(2:end)'];
    
    LOPC.Vert.Binned_Biomass(a,:,[1 3 4]) = 4./3.*pi.*((LOPC.Vert.Binned_ESD(a,:,[1 3 4])./2).^3).*LOPC.NBSS.to_mg;
    LOPC.Vert.Binned_Biomass(a,:,2) = LOPC.Vert.Binned_ESD(a,:,2)./LOPC.Vert.Vol(a);
    
    %Normalised Biomass
    LOPC.Vert.NBSS(a,:) = (LOPC.Vert.Binned_Biomass(a,:,1).*LOPC.Vert.Binned_Biomass(a,:,2))./...
        (LOPC.Vert.Binned_Biomass(a,:,4)-LOPC.Vert.Binned_Biomass(a,:,3));
    
    % Calculate Counts used in NBSS and Average Biomass
    LOPC.Vert.TotalCounts(a,1) = sum(LOPC.Vert.Binned_ESD(a,:,2));
    LOPC.Vert.Counts(a,1) = round(LOPC.Vert.TotalCounts(a)./LOPC.Vert.Vol(a));
    
    LOPC.Vert.Biomass(a,1) = sum(LOPC.Vert.Binned_Biomass(a,:,1).*LOPC.Vert.Binned_Biomass(a,:,2));
    LOPC.Vert.TotalBiomass(a,1) =  LOPC.Vert.Biomass(a,1).*LOPC.Vert.Vol(a);
    
end

