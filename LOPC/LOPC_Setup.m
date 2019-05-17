function LOPC = LOPC_Setup(file,ESD)

% This ducntion sets up a basic LOPC structure with generic fields for use
% with the LOPC Toolbox. A 2-element ESD array [minESD maxESD] in um is optional

% Jason Everett (UNSW)
% Written: 21st June 2016

if nargin == 1
    LOPC.MinESD = 200/1e6;
    LOPC.MaxESD = 3000/1e6;    
else
    LOPC.MinESD = ESD(1)/1e6;
    LOPC.MaxESD = ESD(2)/1e6;
end

if nargin > 0
    LOPC.FileName = file;
end

disp(['Using LOPC Size Range: ',num2str(LOPC.MinESD.*1e6),'um - ',num2str(LOPC.MaxESD.*1e6),'um'])
