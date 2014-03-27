%% Self phase modulation compensation
% Phase rotation due to the nonlinear effect 
% theta = span * gamma * Leff * P
% Leff : Effective length 
% Gamma : fiber gamma 
%  

function ofdmout =  SPMPostComp( ofdmin, launch_pwr_en, fiber, edfa, sim, span, rxedfa, PD  )
    ofdmout = ofdmin ;
    if ( sim.nlpostcompen == 0 )         
        return 
    end
    

    % input power = fiber input power  * rx edfa gain * PD gain *
    %               sqrt(lolaser.launchpower) * PD responsivity;
    if ( launch_pwr_en == 1)
        pwr_mul =  sqrt(sim.Launchpower)/sqrt(mean(sum(abs(ofdmin).^2,1)))   ;
    else
%         pwr_mul = 10^(PD.gain_dB/20) *sqrt(sim.Launchpower)  *  PD.responsivity ;
%         pwr_mul = pwr_mul * 10^(rxedfa.gain_dB /20); 
%         pwr_mul = pwr_mul * sqrt(2)    ;    
%         pwr_mul = 1 /pwr_mul ;  
%         pwr_mul =  pwr_mul* (0.2782);
        pwr_mul =  sqrt(sim.Launchpower)/sqrt(mean(sum(abs(ofdmin).^2,1))) *0.0108 ;
    end        
%     pwr_mul = pwr_mul / sqrt(2)    ;   
    pwr_mul = pwr_mul ^2 ;   
    pwr_mul = pwr_mul * sim.nlc_coef ;
    % Leff : Effective length 
    Leff    =   (1 - exp (- fiber.Alpha * edfa.length))/fiber.Alpha;
    [d1,d2] = size(ofdmin);
    ofdmsig = ofdmin;

    for np=1:d1
        gain =  pwr_mul  * fiber.Gamma *   Leff * span  ;
        if ( d1 == 1 ) % Single polarization 
            nltheta       = gain * (  (abs( ofdmsig(np,:))) .^2 );
        else  %  Dual polarization
            ofdmsigx = ofdmsig(np,:) ;
            ofdmsigy = ofdmsig(mod(np,2)+1,:);
            nltheta       = gain * (   (abs( ofdmsigx)) .^2 +  sim.nlcoef_cross * (abs( ofdmsigy)) .^2  );
        end
        ofdmout(np,:) = ofdmsig(np,:) .* exp (- 1i* nltheta);
    end 
    
end 
