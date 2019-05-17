function ESD = OPC_Digi2ESD(DigiSize)
%
% This function uses the equations and constants from Appendix A of the 
% OPC Users Manual to convert the digital size to equivalent spherical 
% diameters (ESD) in m. The equation is valid for digital sizes in the
% range 7 to 3500. This covers an ESD range of roughly 250 um to 14 mm. 
%
% Useage: ESD = OPC_Digi2ESD(DigiSize)
% 
% Written by Jason Everett (UNSW)
% Equations adapted from Appendix A of the OPC Users Manual
% The Optical Plankton Counter is a product of Focal Technologies.

SqDS = sqrt(DigiSize);
Aa = 10879.8;
Ab = 1.923;
TERM = Aa./((exp(abs(3.65 - ((SqDS.^2)./1e3)))).^Ab);

ESD = ((2088.76 + TERM + 85.85.*SqDS) .* (1-exp(-0.0465.*SqDS + 8.629e-5.*(SqDS.^2))))./1e6; % ESD in m
