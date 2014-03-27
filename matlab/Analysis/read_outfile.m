function  [ X_coor, bit_err, Q ]=read_outfile( matfile)

  km=1000;
%   str1='opt';
%     if ( sim.en_read_ADS ==0 && sim.en_gen_ADS==0 )
%         str1='matlab';
%     end
%     matfile =[ dir, str1,'_', ...
%               num2str(params.NFFT), '_',  ...
%               num2str( 2^params.Nbpsc ),'QAM_', ...
%               num2str(sim.precomp_en),'prec_', ...
%               num2str(sim.mode),'mode_', ...
%               num2str(sim.FiberLength/80/km),'span', ...
%               ]; 

    tmp =dlmread(matfile);
    bit_err=tmp(1,:); 
   
   Q= tmp(2,:); 
   X_coor= tmp(3,:); 
end
   