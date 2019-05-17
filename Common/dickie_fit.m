function NBSS = dickie_fit(param,Bio)

A = param(1);
B = param(2);
C = param(3);

NBSS = A - (-C/2) * (Bio-B).^2;