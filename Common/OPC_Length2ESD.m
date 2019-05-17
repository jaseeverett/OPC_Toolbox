function ESD = OPC_Length2ESD(L,ellipse)

% Ellipse is the ratio of length to width.
%
% Useage: ESD = OPC_Length2ESD(L,ellipse)


W = L/ellipse; % Width is a fraction of the length;
A = pi * W/2 * L/2;

ESD = (sqrt(A/pi)).*2;

