function BER =  idealBER_EBNO( EBNO_dB, k)
% k : 
% M-QAM 
M= 2^k;

% Linear Eb No 
EbNo =10.^(EBNO_dB/10) ;

% Average energy per symbol 
EavNo = EbNo * k; 

% Symbol Error rate 
SymbolErrorRate = 2*(1-1/sqrt(M))*erfc( sqrt(3/2/(M-1) .* EavNo));

% BER can be obtained from SER (Approxmimation)
BER = SymbolErrorRate/k;
     
end 