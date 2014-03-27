function txfile = gennerate_AWG( en, optiout, optidata, dir_name, params, sim, edfa )
    span =ceil( sim.FiberLength/edfa.length);
    
    qam_str = num2str( 2^params.Nbpsc );   
    if ( sim.noClip  == 1 )
        clip_str = 'NoClip';
    else
        clip_str = [num2str(sim.Clipping_dB), 'C'];
    end

    LP_str=[  ''];
    if ( sim.nlcompen == 1  )
        if ( sim.LP_dB < 0 )
            LP_str=[ '_m', num2str( abs(sim.LP_dB) ),'dBm'];
        else
            LP_str=[ '_', num2str( abs(sim.LP_dB) ),'dBm'];
        end
    end
    
    pre_str='';
    if ( sim.preemphasis_H_en == 1 )
        pre_str = '_OPRE';
    end
%     stim= [ dir_name, 'TX',  '_',  qam_str, 'QAM_', ...
        stim= [   qam_str, 'Q_', ...
            clip_str, ... 
              '_CFO', num2str(sim.cfotype), ...
              '_SC', num2str(length(params.LTFindex)), ...
              'E', num2str(length( params.AddEdgeSc)), ...
              pre_str, LP_str, ...
             ...
            ];
%    stim= [ dir_name, 'TX', num2str(params.NFFT), '_', qam_str, 'QAM_', ...
%             num2str(params.Nstream), 'POL_', num2str(sim.cfotype),  'CFO_', ...
%             num2str(sim.MAXSIM), 'frames', ...
%             ];
%     
    txfile =stim;
    if ( en == 0)
        return 
    end
    
%     if ( params.Nstream ==2 )        
%         opti2_i = [ optiout_time; real(optiout(2,:))];
%         opti2_q = [ optiout_time; imag(optiout(2,:))];    
%     end
    
%     optiout = Change_fixed_bit_lim( optiout, 8, 0.0228 );
    if ( params.Nstream ==1 )
        filename =[ dir_name, stim, '_I', '.txt'];
        dlmwrite( filename, real( optiout(1,:) )', 'newline' , 'pc');

        disp(['Writing file', filename]);
        filename =[dir_name,  stim, '_Q', '.txt'];
        dlmwrite( filename, imag( optiout(1,:) )', 'newline' , 'pc');

        disp(['Writing file', filename]); 
    end
    if ( params.Nstream ==2 )
        ISFA_edge ='';
        if ( params.ignore_edge_sb == 1) 
            ISFA_edge =['_E', num2str(length( params.AddEdgeSc))];
        end
        filename =[ dir_name, 'DP_', stim, '_1I',   '.txt'];
        dlmwrite( filename, real( optiout(1,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]);
        
        filename =[dir_name, 'DP_', stim, '_1Q',   '.txt'];
        dlmwrite( filename, imag( optiout(1,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]); 
        
        filename =[ dir_name, 'C1_', stim,   '.txt'];
        dlmwrite( filename, real( optiout(1,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]);
        
        filename =[dir_name, 'C3_', stim,   '.txt'];
        dlmwrite( filename, imag( optiout(1,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]); 
        
        filename =[ dir_name,'C2_', stim,  '.txt'];
        dlmwrite( filename, real( optiout(2,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]); 

        filename =[ dir_name, 'C4_',stim,   '.txt'];
        dlmwrite( filename, imag( optiout(2,:) )', 'newline' , 'pc');
        disp(['Writing file', filename]); 
    end    

end