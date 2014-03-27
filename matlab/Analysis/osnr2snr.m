function SNR_dB = osnr2snr(OSNR_dB, Rs)
    OSNR = 10 .^(OSNR_dB/10);
   
    GHz=1e9;
    BRef = 12.5 *GHz; %
    SNR = OSNR * 2*BRef/Rs;
    
    SNR_dB = 10*log10(SNR);
end 