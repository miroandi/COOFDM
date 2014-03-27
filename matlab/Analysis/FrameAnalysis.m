function [frame, rxidealout,EVM_dB_sc, EVM_dB_sym ]=  FrameAnalysis( dataf,demapperout, fftout, cfo_phase, params, sim , snr )
    rxidealout = NMapper( demapperout,  params );
    error = abs(fftout-rxidealout);
    signal = abs(fftout);
    EVM_dB = 10*log10(sum(error .^2 )/sum(signal .^2 ));

    txidealout     = NMapper( dataf,  params );
    if ( params.MIMO_emul == 1 )
        txideal1 = txidealout(1,params.Nsd+1:size(txidealout,2));
        rxideal1 =rxidealout(1,:) ;
        rxideal = rxidealout(2, 1:size(txidealout,2)-params.Nsd) ;
        txideal = txidealout(1,1:size(txidealout,2)-params.Nsd);
        
        diff_rtx=find ( rxideal1 ~= txideal );
        diff_rtx2=find ( rxideal ~= txideal1 );        
        ErrBit = length( find (real(rxideal1) ~= real(txideal1))) + ...
            length( find (imag(rxideal1 ~= imag(txideal1)))) + ...
            length(  find( real( txideal) ~= real( rxideal) )) + ...
            length(  find( imag( txideal) ~= imag( rxideal) )) ;
    else
        diff_rtx=find ( rxidealout ~= txidealout);
        diff_rtx2 =[];
    end
%     figure;plot(mod(a, params.Nsd));
    %% EVM as a function of Subcarrier 
    rxidealout_sc = reshape( rxidealout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );
    fftout_sc = reshape( fftout(1,:), params.Nsd , length(fftout(1,:))/params.Nsd );

    if ( params.Nstream == 2 )
        rxidealout2_sc = reshape( rxidealout(2,:), params.Nsd , length(fftout(2,:))/params.Nsd );
        fftout2_sc = reshape( fftout(2,:), params.Nsd , length(fftout(2,:))/params.Nsd );
    end


    for ii=1:size(fftout,1)
        fftout_sc = reshape( fftout(ii,:), params.Nsd , size(fftout, 2)/params.Nsd );
        fftout_sym =(transpose(fftout_sc));% conj(reshape( fftout(ii,:)',  size(fftout, 2)/params.Nsd, params.Nsd ));
        rxidealout_sc = reshape( rxidealout(ii,:), params.Nsd , size(fftout, 2)/params.Nsd );
        error = abs(fftout_sc-rxidealout_sc);
        signal = abs(fftout_sc);
        EVM_dB_sc(:,ii) = 10*log10(sum(error .^2, 2 )./sum(signal .^2,2 ));
        rxidealout_sym  = (transpose(rxidealout_sc));%conj(reshape( rxidealout(ii,:)', length(fftout)/params.Nsd,params.Nsd  ));
        error = abs(fftout_sym-rxidealout_sym);
        signal = abs(fftout_sym);
        EVM_dB_sym  = 10*log10(sum(error .^2, 2 )./sum(signal .^2,2 ));
        [snrt(ii), OSNRt(ii), ESNR(ii) ] = get_snrf(fftout_sc, rxidealout_sc, params, sim );
    end

%     cfo_err(SNRsim) = cfo_err(SNRsim)+ ( sim.exp_cfo - cfo_phase)^2;
    
% cfo_phase = 2* cfo_phase * params.NFFT /pi/2 ;
% cfo_phase = cfo_phase/2/pi ;
frame.cfo_err =( sim.exp_cfo - cfo_phase)^2;
if ( params.MIMO_emul == 1 )
    demapper1 = demapperout(find(mod((1:size(demapperout,2))-1, params.Nbpsc*2) <= (params.Nbpsc-1)));
    demapper2= demapperout(find(mod((1:size(demapperout,2))-1, params.Nbpsc*2) > (params.Nbpsc-1)));
   
    aa=find(mod((1:size(dataf,2))-1, params.Nbpsc*2) <= (params.Nbpsc-1));
    dataf0 = dataf(aa);
    dataf1= dataf0(1,params.Nsd*params.Nbpsc+1:size(dataf0,2));
    dataf2= dataf0(1,1:size(demapper2,2) );
    a=find(bitxor( dataf2 , demapper1) == 1 );
    b=find(bitxor( dataf1 , demapper2) == 1 );     
%     frame.Nbiterr =length(find(mod(a-1, params.Nbpsc*2) < (params.Nbpsc-1))) ; % Ignore Stream2 
    frame.Nbiterr = [length(a),length(b)];   
%     frame.Nbiterr = length(a)+length(b);
else
    frame.Nbiterr =length(find(bitxor( dataf , demapperout) == 1 ));
end
frame.BER = frame.Nbiterr/ params.totalbits;
% frame.snr = mean( 10*log10(snrt / params.NFFT * (params.NFFT-size(params.LTFindex,2) )));
frame.snr = mean(snrt);
frame.OSNR = snr2osnr( frame.snr, 1 /params.SampleTime );
frame.ESNR = mean(ESNR);
frame.EVM_dB =EVM_dB;
frame.cfo_phase = cfo_phase;
frame.diff_rtx =diff_rtx;
frame.diff_rtx2 =diff_rtx2;
frame.syncpoint = sim.syncpoint;
frame.EVM_dB_sc =EVM_dB_sc;
frame.EVM_dB_sym =EVM_dB_sym;
frame.fftout =fftout;
frame.idealout =rxidealout;
end