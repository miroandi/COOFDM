function AOUT = AddAWGN( AIN, SNRdB, sim);

    active_data =  (sim.oversample * sim.zerohead2)+1: ...
        (size(AIN,2)-(sim.zeropad+sim.zeropad1+sim.zeropad2+sim.zeropad3)*sim.oversample);
    signal_energy = mean( AIN(:,active_data) .* conj(AIN(:,active_data)),2 );
    SNR=10 .^(SNRdB/10);
    No=(signal_energy ./SNR);
    noise= zeros(size(AIN));
    for ii=1:size(AIN,1)
        noise(ii,:)=sqrt(No(ii)) *(randn(1, size(AIN,2)) + 1j*randn(1, size(AIN, 2)));
    end
        
    AOUT =  noise/sqrt(2) ;
end