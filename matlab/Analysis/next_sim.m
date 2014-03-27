function  break_sim = next_sim( sim, totbiterror, numsim,maxsim,bit_err_sim ,SNRsim)

break_sim=0;
% Simulation stop condition 
if ( totbiterror > sim.stopcnt  && numsim > (maxsim * 0.2) && numsim > 100 )
    if ( (abs( bit_err_sim(SNRsim, numsim-1) - bit_err_sim(SNRsim, numsim) ) ...
            < (bit_err_sim(SNRsim, numsim) * 1e-3)) && ...
        (abs( bit_err_sim(SNRsim, numsim-10) - bit_err_sim(SNRsim, numsim) ) ...
            < (bit_err_sim(SNRsim, numsim) * 1e-3)) )
        disp(['the number of simulations :', num2str( numsim ), '. ']);
        break_sim=1;
    end
    
end
