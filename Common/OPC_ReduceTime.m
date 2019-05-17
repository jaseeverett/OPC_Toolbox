function out = OPC_ReduceTime(out,fi)

if strcmp(out.Unit,'LOPC')==1 | strcmp(out.Unit,'Logger')==1

out.SEPS = out.SEPS(fi,:);
            out.SMEP = out.SMEP(fi,:);
            out.CPS = out.CPS(fi,1);
            out.Abund = out.Abund(fi,1);
            out.datenum = out.datenum(fi,1);
            out.deltaTime = out.deltaTime(fi,1);
            out.secs = out.secs(fi,1);
            out.CTD = reduce_struct(out.CTD,fi);
            out.Eng = reduce_struct(out.Eng,fi);
            out.Flow = reduce_struct(out.Flow,fi);
            clear fi
            
else
    error('Unit not identified')
end