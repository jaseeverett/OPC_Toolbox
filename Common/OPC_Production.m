clear
close all

% From Basedow et al 2014

% Growth was computed based on the observed data on temperature, chl a 
% and zooplankton in three steps: 
    % (1) binning zooplankton counts into 56 size bins that were equally 
% spaced on a logarithmic scale, 
    % (2) computing weight w (in mg C individual? 1) for each size bin by 
% converting biovolume to carbon and 
    % (3) computing weight- specific growth g (in day?1) for each 
% size bin according to Zhou et al. (2010) and Hirst and Bunker (2003), see 
% below. 

% Production P (normalised by size bin) is then given as  
% P1?4g0w0N=dw in mg C m?3 d?1 ð3Þ
% where N is the abundance in individuals m?3. Two different methods to 
% estimate growth were compared: first the purely empir- ical estimates by 
% Hirst and Bunker (2003), and secondly the combined theoretical?empirical 
% estimates by Zhou et al. (2010). 

% Using Hirst and Bunker (2003) (their Table 6) weight-specific growth 
% (g, day? 1) is given as
% gðw; T; CaÞ 1?4 10aT wbCca10d ð4Þ
% where w is the body weight in ?g carbon individual? 1, T the temperature 
% in °C, Ca the food concentration in mg chl a m? 3, and a, b, c and d are 
% constants equal to 0.0186, ?0.288, 0.417 and ?1.209, respectively (Hirst 
% and Bunker, 2003). Zhou et al. (2010) derived a semi- empirical equation 
% to estimate growth by combining the empirical equations of Hirst and 
% Bunker (2003) with the theoretical defini- tions of growth by Huntley and 
% Boyd (1984) and with theoretical and empirical considerations in relation 
% to clearance rate. Weight- specific growth is then defined as
% h i gðw; T; CaÞ 1?4 0:033 Ca= Ca þ 205e?0:125T e0:09T w?0:06 ð5Þ
% where w is in mg C individual? 1 and Ca in mg carbon m? 3 (Zhou et al., 
% 2010, their Eq. 19). For both methods, i.e. Hirst and Bunker (2003) and 
% Zhou et al. (2010), body volume of the particles was converted into carbon 
% using a ratio of mg carbon = 0.0475 body volume (Gallienne et al., 2001). 
% For the method of Zhou et al. (2010) chl a was converted to car- bon (C) 
% using a ratio of C:chl a = 50, which is a ratio commonly ob- served 
% (e.g. Reigstad et al., 2008). The sensitivity of modelled growth estimates 
% to the conversion ratios was tested by applying a range of other ratios: 
% for C:body volume these were 0.02375, 0.04275, 0.05225 and 0.07125 
% (corresponding to a change of ?50%, ?10%, +10% and + 50% of the original 
% conversion factor), and for C:chl a the ratios tested were 25, 75 and 100 
% (Table 5). The comparison of the methods by Hirst and Bunker (2003) and 
% Zhou et al. (2010) was restricted to older stages of Calanus spp. (large, 
% more opaque particles), because this group is the most homogeneous 
% functional group identified by the LOPC.
% 
% Production in relation to water mass was estimated for all size groups 
% based on the method by Zhou et al. (2010). First, production was calculated 
% for each data point along the transect, and secondly mean production within 
% the different water masses (ArW, AtW, PFW, and MW) was computed by 
% averaging production estimates from those data points where salinity and 
% temperature matched the charac- teristics of the respective water masses.
% 2.7. Estimating mortality and population change rates
% Zhou et al. (2010) derived a very simple equation to estimate mortality 
% within a time period t based on in situ observations of biomass spectra.

% Number-specific mortality (?, day?1) is given by
% ?ðw;tÞ1?4gS ð6Þ
% where S is the slope of the biomass spectrum (Zhou et al., 2010, their 
% equation 24) The slope of the biovolume spectrum can be used analogously 
% because the specific ratio between biomass to biovolume is can- celled 
% between numerator and denominator when computing the spectra. Based on the 
% observed biovolume spectra and Eq. (6), we esti- mated mortality rates 
% for the different mesozooplankton size groups (Table 3) and the different 
% water masses at the Polar Front. First, we computed the slope for the 5 
% different size groups (S: 0.25?0.6 mm ESD, M: 0.6?1 mm ESD, L: 1?2 mm ESD, 
% XL: 2?4 mm ESD and 2XL: 4?10 mm ESD; Table 3) and the four different water 
% masses (described below) by fitting linear regression lines to the data. 
% Secondly, mortality was computed following Eq. (6) by multiplying weight-
% specific growth g (Eq. (5)) with the appropriate slope. Similar to 
% production estimates (Eq. (3)), population loss L, normalised by size bin, 
% was computed:
%   
% L1?4?0w0N=dw in mg C m?3d?1 : ð7Þ
% Combining Eqs. (5) and (6), we analysed population dynamics by computing 
% the total change in C d? 1 within the mesozooplankton com- munity, i.e. 
% the population rate, as
%   
% Population rate1?4ðgþ?Þ0w0N=dw in mg C m?3d?1 ð8Þ

