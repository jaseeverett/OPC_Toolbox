function ESD = OPC_Bio2ESD(OPC,Ellipsoid)





if isstruct(OPC) == 1 && nargin == 1
    
%     to_mg = OPC.NBSS.to_mg;
%     Ellipsoid = OPC.Param.Ellipsoid;
%     
%     w = sqrt((OPC.Pareto.ParArea./pi)/Ellipsoid);
%     
    
elseif nargin == 2
  
    Bio = OPC;
    to_mg = 1e9;
    
    V = Bio./to_mg;
    
    w = nthroot((V/(4/3*pi))/Ellipsoid,3);
    l = Ellipsoid*w;
    
    ESD = sqrt(l.*w).*2;
    
    
else
    error('Error in OPC_SD2Bio - Incorrect number or format of input variables')
    
end



