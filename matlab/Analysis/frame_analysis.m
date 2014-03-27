
idealout = NMapper( demapperout,  params );
error = abs(fftout-idealout);
signal = abs(fftout);
EVM_dB = 10*log10(sum(error .^2 )/sum(signal .^2 ));


if ( sim.en_constellation_plot == 1 )  
    idealout = NMapper( demapperout,  params );
    figure;
    if ( params.Nstream == 2 )
        
%         subplot(2,1,1);
        plot(fftout(1,:), '*'); hold;
        plot(idealout(1,:), 'r*'); hold;
        ylim([-1.5 1.5]);xlim([-1.5 1.5]); 
%         subplot(2,1,2);
        plot(fftout(2,:), '*'); hold;
        plot(idealout(2,:), 'r*'); hold;
        ylim([-1.5 1.5]);xlim([-1.5 1.5]);
    else
        
        plot(fftout(1,:), '*'); hold;
        plot(idealout(1,:), 'r*'); hold;
        ylim([-1.5 1.5]);xlim([-1.5 1.5]);        

    end
end

en_plot=1;

idealout_sc = reshape( idealout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );
fftout_sc = reshape( fftout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );

if ( params.Nstream == 2 )
    idealout2_sc = reshape( idealout(2,:), params.Nsd , length(fftout(2,:))/params.Nsd );
    fftout2_sc = reshape( fftout(2,:), params.Nsd , length(fftout(2,:))/params.Nsd );
end


if ( en_plot == 1 )
    for ii=1:size(fftout,1)
        fftout_sc = reshape( fftout(ii,:), params.Nsd , size(fftout, 2)/params.Nsd );
        fftout_sym =(transpose(fftout_sc));% conj(reshape( fftout(ii,:)',  size(fftout, 2)/params.Nsd, params.Nsd ));
        idealout_sc = reshape( idealout(ii,:), params.Nsd , size(fftout, 2)/params.Nsd );
        error = abs(fftout_sc-idealout_sc);
        signal = abs(fftout_sc);
        EVM_dB_sc = 10*log10(sum(error .^2, 2 )./sum(signal .^2,2 ));
        idealout_sym  = (transpose(idealout_sc));%conj(reshape( idealout(ii,:)', length(fftout)/params.Nsd,params.Nsd  ));
        error = abs(fftout_sym-idealout_sym);
        signal = abs(fftout_sym);
        EVM_dB_sym  = 10*log10(sum(error .^2, 2 )./sum(signal .^2,2 ));
        [snr(ii), OSNR(ii), ESNR(ii)] = get_snrf(fftout_sc, idealout_sc, 1/params.SampleTime);
    end
end
cfo_err(SNRsim) = cfo_err(SNRsim)+ ( sim.exp_cfo - cfo_phase)^2;
% % 
% % for nsymbol=1:params.NSymbol
% %         onesymbol = ovoptofdmout((nsymbol-1)* params.SampleperSymbol +1:(nsymbol)* params.SampleperSymbol);
% %         Papr(nsymbol) = min(30, max(1,floor (getPapr1( onesymbol, ...
% %         launch_power)+0.5) ));
% %         rx=demapperout((nsymbol-1)*params.Ncbps+1:params.Ncbps*nsymbol);
% %         tx=dataf((nsymbol-1)*params.Ncbps+1:params.Ncbps*nsymbol);
% %         biterror(Papr(nsymbol))= biterror(Papr(nsymbol)) + ...
% %                                  length(find(bitxor( rx , tx) == 1 ));
% %         totbit(Papr(nsymbol))= totbit(Papr(nsymbol)) + params.Ncbps;
% % end
% evm = evm + abs(fftout-mapperout).^2 ;
frame.Nbiterr =length(find(bitxor( dataf , demapperout) == 1 ));
frame.BER = frame.Nbiterr/totalbits;
frame.snr = mean(snr);
frame.OSNR = mean(OSNR);
frame.ESNR = mean(ESNR);
frame.EVM_dB =EVM_dB;



% plot([exp( -1j*1*commonphase  ) -exp( -1j*1*commonphase  )], 'r*'); ylim([-1.5 1.5]);xlim([-1.5 1.5]);
% run_anal(fftout_sym, fftout_sym, idealout_sym, 'sym');
% plot(rxphase_noise+txphase_noise)
cidx=params.SampleperSymbol*((params.NLTF+params.NSTF)+(1:length(commonphase)));
% plot( cidx, commonphase)

if ( mod(numsim,100) ==0 || numsim == sim.MAXSIM )    
    str = ['the number of simulations :', num2str( numsim),  ...
     ' BER:',  num2str(totbiterror/( numsim *totalbits)), ...
    ' CurSim: ', num2str(X_coor(SNRsim)) ] ;   
    disp2(logfile, str);
end   

      

totbiterror=totbiterror + frame.Nbiterr;
totESNR = totESNR + frame.ESNR;
bit_err_sim(SNRsim, numsim) = max(1e-9, totbiterror/( numsim *totalbits));
err_num(SNRsim, numsim) = frame.Nbiterr;
esnr(SNRsim,numsim) = frame.ESNR;
