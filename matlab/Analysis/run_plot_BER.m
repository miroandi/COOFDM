k=4;
nsamp=1; % oversample 
% osnr
% snr = [ 16,15,14,13,12];
% measureBer= [1.5e-5 5.5e-5 0.0017 0.028  0.17];

snr = 10:2:18;
measureBer= [6.5e-2, 1.7e-2, 1.7e-3, 2.5e-4, 4.0e-5];

EbNo = snr - 10*log10(k)-10*log10(nsamp);
DSPBer = [ 0.0079271,0.0017257, 3.160e-004,  3.47e-6, 1e-12];
DSPBer1 = [ 5.663e-003,0.0010417,2.361e-004,  3.472e-006, 1e-12];
DSPBer2 = [ 4.698e-003,7.847e-004,1.736e-5,  1.39e-6, 1e-12];

theoryBer = (1/2)*erfc(sqrt(10.^(EbNo/10)));
figure;hold;
% semilogy(EbNo,theoryBer,'bs-','LineWidth',2, 'Display', 'Theory');
% xlabel('Eb/No, dB')
% ylabel('Bit Error Rate')
% title('Bit error probability curve for M-QAM using OFDM')
GHz=1e9;
semilogy(snr2osnr(snr, 10*GHz),theoryBer,'bs-','LineWidth',2, 'Display', 'Theory');
xlabel('OSNR (dB )')
ylabel('Bit Error Rate')
title('Bit error probability curve for M-QAM using OFDM')

semilogy(EbNo,measureBer,'rs-','LineWidth',2,'Display', 'measured');
semilogy(EbNo,DSPBer,'gs-','LineWidth',2,'Display', 'DSP');
semilogy(EbNo,DSPBer1,'yo-','LineWidth',2,'Display', 'ZF+ISFA');
semilogy(EbNo,DSPBer2,'yo-','LineWidth',2,'Display', 'ZF+ISFA+NonPreemp');

legend show;

figure;hold;
osnr = [12 11 10 9 8 ];
legend('theory', 'simulation');
xlabel('OSNR, dB')
ylabel('Bit Error Rate')
title('Bit error probability curve for M-QAM using OFDM')
semilogy(osnr,measureBer,'rs-','LineWidth',2,'Display', 'measured');