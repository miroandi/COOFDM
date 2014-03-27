function run_anal( fftout_sc,fftout3_sc, evmout, str)
    for ii=1:size(fftout_sc,1)
      plot(evmout,'r*'); hold; 
      
      xlabel( [ str, ' ',  num2str(ii),' constellation'] );
      plot(fftout_sc(ii, :),'*') ;xlim([-1.5 1.5]) ;ylim([-1.5 1.5]) ; 
%       plot(fftout3_sc((ii-1)*1+1:ii*1, :),'g*');
      hold ; ii
    end
end