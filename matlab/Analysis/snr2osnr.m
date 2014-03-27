function OSNR_dB =  snr2osnr( SNR_dB, Rs)
    SNR = 10 .^(SNR_dB/10);
   
    GHz=1e9;
    BRef = 12.5 *GHz; %
    OSNR = SNR * Rs/2/BRef ;
    
    OSNR_dB = 10*log10(OSNR);
end 