function EbNo_dB =  SNR2EbNo( SNR_dB, CPratio, Nsd, Nsp,Nbpsc,  NFFT)

% Signal power = No of bits * Eb 
% Signal power of one symbol = No of bits of one symbol * Eb
% Nsp: Number of pilot subcarrier 
% Nsd = Number of data subcarrier 
% SNR = 10.^(SNR_dB/10);
 
 
    EsNo_dB = SNR_dB -10*log10( 1+CPratio);
    EbNo_dB = EsNo_dB - 10*log10( (Nsd+Nsp)/NFFT) + 10*log10(1+CPratio) ...
        - 10*log10(Nbpsc) ;
   

end 