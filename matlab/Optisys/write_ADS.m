function write_ADS( filename, signal )

    dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
    dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
    dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
    dlmwrite(filename,  signal','-append', 'delimiter', '\t','newline' , 'pc','precision', 7)

end