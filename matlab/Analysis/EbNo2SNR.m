function SNR_dB =  EbNo2SNR( EbNo_dB, CPratio, Nsd, Nsp,Nbpsc,  NFFT)

% Signal power = No of bits * Eb 
% Signal power of one symbol = No of bits of one symbol * Eb
% Nsp: Number of pilot subcarrier 
% Nsd = Number of data subcarrier 
% SNR = 10.^(SNR_dB/10);
 
EsNo_dB = EbNo_dB + 10*log10( (Nsd+Nsp)/NFFT) - 10*log10(1+CPratio) ;

    SNR_dB= EbNo_dB + 10*log10( (Nsd+Nsp)/NFFT) - 10*log10(1+CPratio) + 10*log(Nbpsc*Nsd/NFFT);
end 