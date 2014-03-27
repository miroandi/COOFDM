function disp2(logfile, str);
    disp(str);
    dlmwrite( logfile,  str,'-append', 'delimiter', '','newline' , 'pc','precision', 7)
end