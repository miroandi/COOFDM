function EbNo_dB =  EsNo2EbNo( EsNo_dB, CPratio, Nsd, Nsp, Nbpsc, NFFT)

% Signal power = No of bits * Eb 
% Signal power of one symbol = No of bits of one symbol * Eb
% Nsp: Number of pilot subcarrier 
% Nsd = Number of data subcarrier 
% SNR = 10.^(SNR_dB/10);
 
% EsNo = 1/(1+CPratio) *(Nsp+Nsd)/NFFT .* EbNo * Nbpsc ;
EbNo_dB = EsNo_dB - 10*log10( (Nsd+Nsp)/NFFT) + 10*log10(1+CPratio) - 10*log(Nbpsc);

end 