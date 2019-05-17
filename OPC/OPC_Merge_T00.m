function OPC_Merge_T00(dir,in_file,out_file,start_prefix, end_prefix)



for a = start_prefix:end_prefix

    if a < 10
        file = [dir,filesep,in_file,'.T0',num2str(a)];
    else
        file = [dir,filesep,in_file,'.T',num2str(a)];
    end
    
    file
    
    fid = fopen(file,'r');
    
    C = textscan(fid, '%s','delimiter','\n');
    data = C{1};
  
    if a == start_prefix
        out = data(1);
    end
    out = [out; data(2:end-2)];
    
   
    
end

fid = fopen([dir,filesep,out_file],'w');

fprintf(fid,'%s\n',out{:});
fclose(fid);