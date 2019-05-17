clear
close

net = 100;

ellipse = 3; % This is the ratio of length to width.

width = net;
length = ellipse*net;

A = pi * (width/2) * (length/2);

ESD = (sqrt(A/pi)).*2
