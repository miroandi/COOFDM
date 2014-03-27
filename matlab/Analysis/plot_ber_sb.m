function  plot_ber_sb( sim, params, X_coor, Y1, Y2 , edfa, laser )
  

    km=1000;MHz=1e6;
    shape(1)='s'; shape(2)='o';shape(3)='<'; shape(4)='d';
    shape(5)='x'; shape(6)='.'; shape(7)='.'; shape(9)='*';
    couleur(1) ='b'; 
    couleur(2) ='r';
    couleur(3) ='g';
    couleur(4) ='m';
    couleur(5) ='y';
    couleur(6) ='k';
    couleur(7) ='c';    
    couleur(9) ='g';
    
    color_str = couleur(sim.precomp_en+1);
    shape_str =[shape(sim.precomp_en+1) '-'];
    if ( sim.precomp_en == 0 )
        legend1 = ['Conventional OFDE']  ;
    else
        legend1 = ['Proposed'];
    end
    legend2 = [ ' N_O_F_D_E ', num2str(params.NOFDE )];
    legend_str='';
    if ( sim.mode ==  1 )     legend_str =[ legend1,', ', legend2 ]; end    
    if ( sim.mode ==  2 )     legend_str =[ legend1, ', ', legend2 ]; end    
    if ( sim.mode ==  4 )     legend_str =[ legend1, ', ', legend2 ]; end    
    if ( sim.mode ==  6 )     legend_str =[ legend1,', '    ]; end
    if ( sim.mode ==  5 )     color_str =couleur(sim.subband+1); end
    
    hold on;
    
    tt =1;
    if ( sim.mode == 6 )   tt=MHz *params.SampleTime*144; end %params.repSTF*params.rep2STF; end
    
%     semilogy( tt* X_coor, BER2Q(Y1(1:length(X_coor))), ...   
%         [ color_str shape_str ], ...
%         'MarkerFaceColor', color_str, ...
%          'Display', legend_str);
 semilogy( tt* X_coor,  (Y1(1:length(X_coor))), ...   
        [ color_str shape_str ], ...
        'MarkerFaceColor', color_str, ...
         'Display', legend_str);
%      plot( tt* X_coor,( Y2(1:length(X_coor)) ), ...   
%         [ color_str shape_str ], ...
%         'MarkerFaceColor', color_str, ...
%          'Display', legend_str);
%      
%     ylabel('Q ') ; xlabel1 =' FiberLengths ' ; 
    ylabel(' (BER) ') ; xlabel1 =' FiberLengths ' ; 
    str1='';
    if ( sim.mode ==  2 )      ylabel('Q ') ;  end
    if ( sim.mode ==  2 )      xlabel1 ='OSNR(dB) ' ;  str1='';    end
    if ( sim.mode ==  4 )      xlabel1 ='SNR(dB) ' ;  str1='';    end
    if ( sim.mode ==  1 )      xlabel1='Fiber Length(km) ' ;  str1=['NF ' num2str( edfa.NF_dB) 'dB '];   end    
    if ( sim.mode ==  3 )      xlabel1='EDFA NF ' ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];   end
    if ( sim.mode ==  5 )      xlabel1='Fiber Length(km) ' ;  str1=['SNR ' num2str( sim.SNR(1)) 'dB '];   end    
    if ( sim.mode ==  6 )      xlabel1='CFO frequency '  ;  str1=['Fiber length' num2str(sim.FiberLength/km) 'km '];   end
    if ( laser.freqoff ~= 0 && sim.mode ~= 6 ) 
        str2 = ['Freq. offset = ', num2str(laser.freqoff /params.SampleTime /MHz), 'MHz' ];
    else
        str2='';
    end
    xlabel(xlabel1);
    title(['BER vs ' xlabel1 'with a given ' str1,str2]);
end
