
%% Automatic gain control
%  To avoid clipping,  maximum amplitude is assumed to be smaller than 
%  4 * average.

function out= NRxAGC ( in, params, sim )
    
    STFidx=params.lenSTF*params.NSTF;
    pwr = abs(in(:, 1:STFidx)) .^ 2;     
    avg_amp = mean(mean(sqrt(pwr)/2, 2) );
    
    if ( sim.ADCbit == 0 )
        out = in ;
    else
        max_val = avg_amp * 10^(sim.ADCClipping/10);
        out = ((in/max_val) *2^( sim.ADCbit-1)+0.5)  ;
    end 
end

    