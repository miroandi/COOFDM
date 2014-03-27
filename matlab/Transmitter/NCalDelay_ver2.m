function [precom_CD, delay, phase,delay_diff ] = NCalDelay_ver2(fiber, params, sim);
    delay = zeros(1, params.NFFT  );
    phase = zeros(1, params.NFFT  );
    precom_CD =0 ;
    delay_diff=0;
    if ( sim.subband ~= 0 )
        subband =  sim.subband  ;
        freq = [  0:(params.NFFT/2-1) -params.NFFT/2:-1];
        freq_diff = -freq + params.NFFT/2 -1;
        deltaF = 1/(params.SampleTime *params.NFFT *params.OVERSAMPLE);
        coef = sim.coeff * -2*pi*fiber.Beta2 *sim.FiberLength *deltaF ;
        delay_float = coef/params.SampleTime * ...
            floor( (-freq+params.NFFT/2 -1 )/(params.NFFT/subband )) * ...
            (params.NFFT/subband ); 
        delay = round(delay_float);
        delay_float_tot = coef / params.SampleTime * freq_diff;
        delay1 = delay_float_tot - delay ;
        phase = 2*pi/(params.NFFT ^2) *( [  0:(params.NFFT/2-1) -params.NFFT/2:-1] .^ 2 .* ( delay1 -delay1(1)  ));
        precom_CD = delay(1);
        
    end
   

    if ( sim.precomp_en == 4 || sim.precomp_en == 2 || sim.precomp_en == 3) 
        deltaF = 1/(params.SampleTime *params.NFFT *params.OVERSAMPLE);
        coef = sim.coeff * -2*pi*fiber.Beta2 *sim.FiberLength *deltaF ;
        max_freq = max([params.SubcarrierIndex1 params.PilotIndex1]);
        min_freq = min([params.SubcarrierIndex1 params.PilotIndex1]);    
        delay_float =[ 0, coef/params.SampleTime * (max_freq + min_freq) ];
        delay_float =coef/params.SampleTime * ((max_freq + min_freq)/2 *[ -1 1 ] + [ 0 1 ]);
        delay_float =coef/params.SampleTime * ((max_freq + min_freq)/2 *[ -1 1 ] );
%         delay_float
        delay = round(delay_float); 
        delay_diff = delay_float(2) - delay(2) ;
        phase = [ zeros( 1, params.NFFT/2), ...
            2*pi/(params.NFFT ^2) *( [ -params.NFFT/2:-1] .^ 2 .* delay_diff )];
        precom_CD = delay(2);
        if ( sim.subband > 2 )            
            middle_sc =   ( (max_freq-min_freq+1) / (sim.subband /2));
            delay_float = [ (0:sim.subband/2-1)* middle_sc + min_freq + (middle_sc-1)/2, ...
                                ((-sim.subband/2:-1)* middle_sc - min_freq +(middle_sc-1)/2 +1)];
%             delay_float = [ (0:sim.subband/2-1)* middle_sc + min_freq + (middle_sc-1)/2+1, ...
%                                 ((-sim.subband/2:-1)* middle_sc - min_freq +(middle_sc-1)/2 )];
%        
            delay_float = -coef /params.SampleTime * delay_float ;
%             delay = 2*round(delay_float/2); 
            delay = round(delay_float); 
            delay = delay ;%- delay(2);
            delay_diff = delay_float - delay ;
%             delay = [    -96  -234   234    96 ];
%             delay = [    -92  -236   236    94];
        end
       
        
    end
    if ( sim.nophase ==1 )
%         phase =phase * 0;
    end
end 
