figure;  hold on; 
[sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD]= InitOFDM_2SB(NFFT, 1,SampleTime );
% CPratio =1/8;
% SampleTime = 1/10/GHz;
X_coor = 6:2:22;
SNR_dB =osnr2snr(X_coor, 1/params.SampleTime);
sim_mode =2;
params.Nbpsc=Nbpsc;
nolinewidth=1;b2b=1;

run('../Run_files/run_BER_precomp.m')


nolinewidth=0;
run('../Run_files/run_BER_precomp.m')


EbNo_dB =  SNR2EbNo( SNR_dB , CPratio, ...
                    2*length(params.SubcarrierIndex1), ...
                    length(params.Pilot), ...
                    params.Nbpsc,  params.NFFT);

BER2 =  idealBER_EBNO( EbNo_dB, params.Nbpsc);
semilogy( X_coor, log10(BER2), 'gs-', 'Display', [num2str(2^params.Nbpsc), 'QAM']); 
ylim([-7 -1])
legend('show');

measureBer= [6.5e-2, 1.7e-2, 1.7e-3, 2.5e-4, 4.0e-5];
X_coor=6:2:14;
% semilogy( X_coor, log10(measureBer), 'rs-', 'Display', [num2str(2^params.Nbpsc), 'QAM Exp']); 

