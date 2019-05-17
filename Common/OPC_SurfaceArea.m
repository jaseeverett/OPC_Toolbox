function OPC = OPC_SurfaceArea(OPC)


if strcmp(OPC.Unit,'InSituLOPC')==1 | strcmp(OPC.Unit,'Logger')==1 | strcmp(OPC.Unit,'LOPC')==1
    OPC.SA = 0.07.*0.07;
    
elseif strcmp(OPC.Unit,'OPC1T') == 1
    OPC.SA = 0.02 * 0.25;
    
elseif strcmp(OPC.Unit,'OPC2T') == 1
    OPC.SA = 0.02 * 0.10;
    
elseif strcmp(OPC.Unit,'LabLOPC') == 1
    OPC.SA = NaN;   
    
elseif strcmp(OPC.Unit,'OPC1L') == 1
    OPC.SA = NaN;   
    
else 
    error('Unit field not detected')
end