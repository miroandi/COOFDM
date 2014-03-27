% Phase rotation due to the nonlinear effect 
% theta = span * gamma * Leff * P
% (ofdmsig * txgain )^2 * laser.launch * 10^(TXEDFA.gain /10)


function ofdmout =  SPMPreComp( ofdmin, fiber, edfa, sim, laser, span, txedfa, MZmod  )
%     pwr_mul= sqrt(laser.launch_power)* sim.txgain ;
%     pwr_mul = pwr_mul * sim.dacout ;
%     pwr_mul = pwr_mul *  pi/MZmod.Vpi_RF/sqrt(2)*10^(txedfa.gain_dB /20);
%     pwr_mul = (pwr_mul )^2 ;
%     pwr_mul = pwr_mul  /sqrt(2)   ;
    [pwr_mul, LP_dB]  = GetLaunchPwr(laser, sim, MZmod, txedfa );
    %LP_dB = 10*log10(pwr_mul) - 9.4857 ;
    pwr_mul = pwr_mul   * sim.nlc_coef ;
    ofdmout = ofdmin;
    Leff =   (1 - exp (- fiber.Alpha * edfa.length))/fiber.Alpha;
    
    if ( sim.nlcompen ==1 ) 
        [d1,d2] = size(ofdmin);
        ofdmsig = ofdmout;
        for np=1:d1
            Wamplitude = mean2( abs( ofdmsig(np,:) )); % Wamplitude unit : sqrt(W)             
            pwr = pwr_mul * abs(ofdmsig(np,:)).^2;
            gain = pwr_mul * fiber.Gamma * Leff * span ;
              
            nltheta       = 1* gain .* sum(abs( ofdmsig(:,:)) .^2, 1 );
            ofdmout(np,:) = ofdmsig(np,:) .* exp (- 1i* nltheta);
            %plot(nltheta)
        end 
    end   
	
    
end 
