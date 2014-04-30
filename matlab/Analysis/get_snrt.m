function [SNR_dB, OSNR_dB, mean_signal_power, mean_noise_power ] = get_snrt(sig1, noise, Rs)
% Time domain SNR estimator
% SNR estimation is very rough. 
% Use only for estimation.


    mean_signal_power = mean(abs(sig1   ) .^ 2,2);
    mean_noise_power = mean(abs(noise).^2,2);


    SNR= (mean_signal_power/  mean_noise_power);
    SNR_dB = 10*log10(SNR);
   
    GHz=1e9;
    BRef = 12.5 *GHz; %
    
    OSNR = Rs/2/BRef * SNR;
    OSNR_dB = 10*log10(OSNR);
end 

% 
% 
% function [SNR_dB, OSNR_dB, mean_signal_power] = get_snr(sig1, params)
% 
% 
%     mean_signal_power = mean(abs(sig1   ) .^ 2);
%     mean_noise_power = mean(abs( fftout(unused_carrier )) .^2 );
% 
%     SNR= (mean_signal_power/  mean_noise_power);
%     SNR_dB = 10*log10(SNR);
%     OSNR_dB=snr2osnr(SNR_dB, 1/params.SampleTime); 
%    
% end 