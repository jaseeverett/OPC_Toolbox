function ESD = OPC_UnWrapBins(Histo,Bins)

if size(Histo,1) ~= 1 && size(Histo,2) ~= 1
    error('Histo must be a 1D Array')
end

s = 1;
fi = find(Histo>0);
ESD = ones(nansum(Histo),1).*NaN;

% Expand Binned Counts to ESD
for ii = 1:length(fi)
    e = s + Histo(fi(ii)) - 1;
    ESD(s:e,1) = repmat(Bins(fi(ii)),Histo(fi(ii)),1);
    s = e + 1;
end