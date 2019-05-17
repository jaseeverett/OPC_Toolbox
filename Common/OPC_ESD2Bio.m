function [Bio,V] = OPC_ESD2Bio(OPC,Ellipsoid)

% This function calculates the biomass of a particle (mg), assuming an given
% ellipsoid ratio (Ellipsoid) and the density of water (OPC.NBSS.to_mg or 1e9).
% OPC can either be a structure from the OPC_Toolbox (in which case this 
% function derives the co-eficients from the OPC structure, or else a vector of
% ESDs. Can also output BioVolume (V) in m3.


% w = short axis radius (width/2)
% A = surface area
% V = Volume
% Bio = Biomass, assuming density of water

% Jason Everett (UNSW) 2018


if isstruct(OPC) == 1 && nargin == 1
    
    to_mg = OPC.NBSS.to_mg;
    Ellipsoid = OPC.Param.Ellipsoid;
    
    w = sqrt((OPC.Pareto.ParArea./pi)/Ellipsoid);
    
    
elseif isstruct(OPC) == 0 & nargin == 2
    ESD = OPC;
    to_mg = 1e9; % Conversion for density of water.
    
    A = pi .* (ESD./2).^2; % Calculate Surface Area of circle with given ESD
    w = sqrt((A./pi)/Ellipsoid); % Calculate short-axis radius (width) given an ellipsoid ratio
    
elseif isstruct(OPC) == 0 & nargin == 1
    ESD = OPC;
    to_mg = 1e9; % Conversion for density of water.
    Ellipsoid = 3;
    disp('No Ellipsoid Ratio given - Assuming 3:1 (L:W)')
    
    A = pi .* (ESD./2).^2; % Calculate Surface Area of circle with given ESD
    w = sqrt((A./pi)/Ellipsoid);  % Calculate short-axis radius (width) given an ellipsoid ratio
    
else
    error('Error in OPC_ESD2Bio - Incorrect number or format of input variables')
    
end

% A2 = pi .* w .* (w .* Ellipsoid);

V = 4./3.*pi.*... % 4/3 * pi * convert to mg
        (w.*Ellipsoid).*... % Length = Width * Ellipsoid
        (w.^2); % Width * Depth (ie Width^2)

Bio = V.*to_mg;