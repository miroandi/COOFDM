function txfile = gennerate_ADS( en, optiout, optidata, dir_name, params, sim, edfa )
    span =ceil( sim.FiberLength/edfa.length);
    
    qam_str = num2str( 2^params.Nbpsc );
    sbstr='';
    if ( sim.precomp_en ~= 0 )% && sim.subband ~= 0 )
        sbstr= ['_', num2str(sim.subband)];
    end
    
    stim= [ dir_name, 'TX', num2str(params.NFFT), '_', qam_str, 'QAM_', ...
            num2str(params.Nstream), 'POL_', num2str(span),  sbstr];
   
    
    txfile =stim;
    if ( en == 0)
        return 
    end
    
% dir_name='D:\user\haeyoung\Project\2012\COOFDM\optisystem\Data\';

    optiout_time = (1:size(optiout,2) )* params.SampleTime- params.SampleTime ;
    opti1_i = [ optiout_time; real(optiout(1,:) )];
    opti1_q = [ optiout_time; imag(optiout(1,:) )]; 
    
    if ( params.Nstream ==2 )        
        opti2_i = [ optiout_time; real(optiout(2,:))];
        opti2_q = [ optiout_time; imag(optiout(2,:))];    
    end
    
    
    filename =[ stim, '_I', '.tim'];
    dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
    dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
    dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
    dlmwrite(filename,  opti1_i','-append', 'delimiter', '\t','newline' , 'pc','precision', 8)
    dlmwrite(filename, ['END'] ,'-append','delimiter','') ;

    filename =[ stim, '_Q', '.tim'];
    dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
    dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
    dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
    dlmwrite(filename,  opti1_q', '-append', 'delimiter', '\t','newline' , 'pc','precision', 8);
    dlmwrite(filename, ['END'],'-append' ,'delimiter','') ;

    filename =[ stim, '.dataf'];
    dlmwrite(filename,  optidata', 'delimiter', '\t','newline' , 'pc')

    if ( params.Nstream ==2 )
        filename =[ stim '_2I', '.tim'];
        dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
        dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
        dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
        dlmwrite(filename,  opti2_i','-append', 'delimiter', '\t','newline' , 'pc','precision', 8)
        dlmwrite(filename, ['END'],'-append' ,'delimiter','') ;

        filename =[ stim '_2Q', '.tim'];
        dlmwrite(filename, ['BEGIN TIMEDATA'] ,'delimiter','') ;
        dlmwrite(filename, ['# T ( SEC V R 50 )'] ,'delimiter','', '-append') ;
        dlmwrite(filename, ['% t v'] ,'delimiter','', '-append') ;
        dlmwrite(filename,  opti2_q', '-append', 'delimiter', '\t','newline' , 'pc','precision', 8)
        dlmwrite(filename, ['END'],'-append' ,'delimiter','') ;
    end
    

   

end