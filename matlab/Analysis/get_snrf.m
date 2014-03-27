function [SNR_dB, OSNR_dB, ESNR] = get_snrf(fftout_sc,ideal_sc, params, sim)
%% Frequency domain SNR estimator
    
    Rs = 1 /params.SampleTime;
%     ESNR = <SNR_k>

    % FFT 
    noise_power_sc = mean(abs( fftout_sc -ideal_sc ) .^2, 2);
    signal_power_sc = mean(abs(fftout_sc ) .^2, 2);
    
    SNR_sc = signal_power_sc ./ noise_power_sc;
    ESNR =mean(SNR_sc,1);
    
    SNR_dB = 10*log10(ESNR);
   
    GHz=1e9;
    BRef = 12.5 *GHz; %
    
    OSNR = Rs/2/BRef * ESNR;
    OSNR_dB = 10*log10(OSNR);
    mean_signal_power = mean(signal_power_sc,1);
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