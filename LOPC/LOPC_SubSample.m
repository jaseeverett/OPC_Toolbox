function s = LOPC_SubSample(s,LOPC)

s.time_min = s.datenum - s.int/2;
s.time_max = s.datenum + s.int/2;

% Preallocate
s.SMEP = zeros(length(s.datenum),size(LOPC.SMEP,2));
s.Flow.Vol = ones(size(s.datenum)).*NaN;
s.Flow.Dist = s.Flow.Vol;
s.Flow.Velocity = s.Flow.Vol;
s.NBSS_Slope = s.Flow.Vol;
s.Counts = s.Flow.Vol;
s.Biomass = s.Flow.Vol;
s.NBSS_r2 = s.Flow.Vol;
s.NBSS_smlBio = s.Flow.Vol;
s.NBSS_Curve = s.Flow.Vol;

s.Flow.FlowUsed = LOPC.Flow.FlowUsed;

% Check that the first bin within the range has data

for i = 1:length(s.datenum)
    
    fi = find(LOPC.datenum >= s.time_min(i) & LOPC.datenum < s.time_max(i));
    
    if ~isempty(fi)
        % Variables I need to subsample....
        s.MinESD = LOPC.MinESD;
        s.MaxESD = LOPC.MaxESD;
        s.Unit = LOPC.Unit;
        s.Sampling_date = LOPC.Sampling_date;
        s.DateProcessed = datestr(now);
        
        LOPC = OPC_Parameters(LOPC);
        s.SMEP(i,:) = sum(LOPC.SMEP(fi,:),1);
        
        s.Flow.Transit.Vol(i,1) = sum(LOPC.Flow.Transit.Vol(fi));
        s.Flow.Transit.Velocity(i,1) = nanmean(LOPC.Flow.Transit.Velocity(fi));
        s.Flow.Transit.Dist(i,1) = sum(LOPC.Flow.Transit.Dist(fi));
        
        if isfield(LOPC.Flow,'Meter')
            s.Flow.Meter.Vol(i,1) = sum(LOPC.Flow.Meter.Vol(fi));
            s.Flow.Meter.Velocity(i,1) = nanmean(LOPC.Flow.Meter.Velocity(fi));
            s.Flow.Meter.Dist(i,1) = sum(LOPC.Flow.Meter.Dist(fi));
        end
        
        s.Flow.Vol(i,1) = sum(LOPC.Flow.Vol(fi));
        s.Flow.Velocity(i,1) = nanmean(LOPC.Flow.Velocity(fi));
        s.Flow.Dist(i,1) = sum(LOPC.Flow.Dist(fi));
        
        %% Get Slopes
        L.Unit = s.Unit;
        L.MinESD = s.MinESD;
        L.MaxESD = s.MaxESD;
        L = OPC_Parameters(L);
        L.SMEP = s.SMEP(i,:);
        
        L.Flow.TotalVol = s.Flow.Vol(i,1);
            
        L = OPC_Pareto(L);
        L = OPC_NBSS(L);

        
        s.Bins_ESD = L.Param.H_Bins;
        
        s.Abundance(i,1) = L.Stats.Abundance;
        s.Biomass(i,1) = L.Stats.Biomass;
        
        s.GeoMn(i,1) = L.Stats.GeoMn;
        s.BinnedBiomass(i,:) = L.NBSS.all.Binned_Bio;
        
        if ~isempty(L.NBSS.Binned_Bio)
            s.NBSS_smlBio(i,1) = L.NBSS.Binned_Bio(1);
        end
        
        s.NBSS_Slope(i,1) = L.NBSS.Lin.Slope;
        s.NBSS_Intercept(i,1) = L.NBSS.Lin.Intercept;
        s.NBSS_r2(i,1) = L.NBSS.Lin.r2;
        s.NBSS_Curve(i,1) = L.NBSS.NLin.Curve;
        s.Counts(i,1) = L.Stats.Total_Counts;
                   
        clear L
    end
end

s.Flow.TotalVol = nansum(s.Flow.Vol);
