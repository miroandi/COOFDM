function [precom_CD, delay, phase,delay_diff ] = NCalDelay_ver2(fiber, params, sim) 
    delay = zeros(1, params.NFFT  );
    phase = zeros(1, params.NFFT  );
    precom_CD =0 ;
    delay_diff=0;
    
    if ( sim.subband ~= 0 )
        % 1. Get phase difference due to CD
        phase_tot = GetChannelPhase( params.NFFT, params.SampleTime, sim.FiberLength, fiber);
        
        % 2. Get center frequencies of each subband.
        freq = [  0:(params.NFFT/2-1) -params.NFFT/2:-1];
        subband_freq = round(freq / (params.NFFT/sim.subband)  );
        freq = freq/(params.SampleTime *params.NFFT *params.OVERSAMPLE);
        subband_freq = subband_freq/(params.SampleTime *params.NFFT *params.OVERSAMPLE);
        
        % 3. Get group delay difference 
        GDD = GetChannelGDD( params.NFFT, params.SampleTime, sim.FiberLength, fiber,subband_freq);
        
        % 4. Get time delay in unit of sampling clock period. 
        delay_float =  GDD/params.SampleTime; 
        delay_float(1) =0 ; 
        delay = round( delay_float);% - min(delay_float));
        
        % 4. Get the residual phase difference due to CD
        phase =  phase_tot  -2 * pi * params.SampleTime * (delay .* freq );
        phase = mod(phase,2*pi);
%         phase =  2*pi*params.SampleTime * ((delay_float -delay) .* freq);
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
        phase =phase * 0;
    end
end 

function phase = GetChannelPhase( NFFT, SampleTime, FiberLength, fiber)
   %% From Phase = pi * D * c /f_c^2 * L * f^2 ,
   %  f = w /(2*pi), and  beta = lambda0^2/(2*pi*c)*D = D * c /f_c^2/(2*pi)
   % Thus, Phase due to CD becomes
   % phase =  1/2 * beta2  * w^2 * L;
    w = [0:NFFT/2-1 -NFFT/2:-1]   ; 
    w= 2*pi * 1/SampleTime/NFFT * w ; 
    phase =   -1/2*fiber.Beta2 *( - w .* w  ) * FiberLength  ;    
      
end


function GDD = GetChannelGDD( NFFT, SampleTime, FiberLength, fiber, delta_freq)
   % GDD = D * L * delta_lamdba = beta2 * (2*pi)  * L * delta_freq 
   % deltaF = 1/(SampleTime * NFFT)
   % deltaLambda =lambda0^2 /  c *deltaF ;
   

%     freq = [0:NFFT/2-1 -NFFT/2:-1]   ; 
%     delta_freq=  1/SampleTime/NFFT * freq ; 
    GDD  = fiber.Beta2 * (2 *pi) * FiberLength * delta_freq  ;  

end