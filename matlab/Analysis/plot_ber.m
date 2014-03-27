function  plot_ber( sim, params, X_coor, bit_err, Q , edfa, laser )
    couleur(64) ='r'; couleur(128)='b';couleur(256)='m';couleur(512)='g';couleur(1024)='k';couleur(2048)='r';
    shape(64) ='>'; shape(128)='d';shape(256)='o';shape(512)='s';shape(1024)='<';shape(2048)='^';
    shape(1)='s'; shape(2)='o';shape(3)='<'; shape(4)='d';
    shape(5)='x'; shape(6)='.';shape(17)='+'; shape(9)='*';shape(33)='p';
    couleur(0+1) ='y'; 
    couleur(1+1) ='r';
    couleur(2+1) ='g';
    couleur(16+1) ='b';
    couleur(4+1) ='c';
    couleur(8+1) ='m';
    couleur(32+1) ='k';
    NFFT=params.NFFT;
    
    color_str = couleur(NFFT);
    if ( sim.precomp_en == 0 || sim.subband == 0 )
        legend1 =  [ 'conv'];  
        shape_str =[shape(params.NFFT) '-'];
    else
        legend1 =  [ 'prop, N_s_u_b_b_a_n_d ', num2str(sim.subband)]; 
        shape_str =[shape(params.NFFT) '--'];
        
    end
    
     if (sim.en_read_ADS ==1)
        shape_str =shape(4); 
     end
    if ( sim.mode ==  5 )     shape_str =shape(subband+1); end
    legend2 = [ ' N_F_F_T ', num2str(params.NFFT)];
    legend3 = [ ' N_F_F_T ', num2str(params.NFFT)];
    if ( sim.mode ==  5 )     legend_str =[ legend1 ]; end
    if ( sim.mode ==  4 )     legend_str =[ legend1 ]; end
    if ( sim.mode ==  3 )     legend_str =[ legend1 ]; end
    if ( sim.mode ==  2 )     legend_str =[ legend1, ', ', legend2 ]; end    
    if ( sim.mode ==  1 )     legend_str =[ legend1,', ', legend2 ]; end
    if ( sim.mode ==  6 )     legend_str =[ legend1,', ', legend2 ]; end
    if ( sim.mode ==  7 )     legend_str =[ legend1,', ', legend2 ]; end
    
    
    if ( sim.mode ==  5 )     color_str =couleur(sim.subband+1); end
    hold on;
    semilogy(X_coor,log10(bit_err(1:length(X_coor))), ...   
        [ color_str shape_str ], ...
        'MarkerFaceColor', color_str, ...
         'Display', legend_str);
%        plot(X_coor, BER2Q( bit_err(1:length(X_coor))), ...   
%         [ color_str shape_str ], ...
%         'MarkerFaceColor', color_str, ...
%          'Display', legend_str);
     
    km=1000;
    ylabel('log_1_0(BER) ') ; 
    if ( sim.mode ==  2 )      xlabel1 ='OSNR(dB) ' ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];    end
    if ( sim.mode ==  4 )      xlabel1='SNR(dB) ' ;   str1=['Fiber length' num2str(sim.FiberLength/km) 'km ']; end
    if ( sim.mode ==  1 )      xlabel1='Fiber Length(km) ' ;  str1=['NF ' num2str( edfa.NF_dB) 'dB '];   end    
    if ( sim.mode ==  3 )      xlabel1='Launch power(mW) ' ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];   end
    if ( sim.mode ==  3 )      xlabel1='EDFA NF ' ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];   end
    if ( sim.mode ==  5 )      xlabel1='Fiber Length(km) ' ;  str1=['SNR ' num2str( sim.SNR(1)) 'dB '];   end    
    if ( sim.mode ==  7 )      xlabel1='Number of subband '  ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];   end
    if ( laser.freqoff ~= 0 ) 
        str2 = ['Freq. offset = ', num2str(laser.freqoff/MHz), 'MHz' ];
    else
        str2='';
    end
    xlabel(xlabel1);
    title(['BER vs ' xlabel1 'with a given ' str1,str2]);
end
