function [fftout, commonphase,timingoffset,snr]  = FFTnComp( fftin, H_in, params, sim, LTF_t, LTF2_t)
   
    d1 = size(fftin,1);
    idx= floor(params.NFFT/2*params.RxOVERSAMPLE * ( params.CPratio)+0.5)*2+1;
    PilotIndex = mod(params.PilotIndex-params.NFFT/2, params.NFFT)-params.NFFT/2;
    fftout=[];
    signal_power = 0;
    noise_power = 0; 
    commonphase =zeros(params.Nstream,params.NSymbol);
    timingoffset =zeros(1,params.NSymbol);
    dfb_cpe=zeros(params.Nstream,1);
    H = H_in;
    ttt=[];
    for symbol=1:(params.NSymbol- params.MIMO_emul )
         %% Channel equalization 
	if ( sim.offset_QAM == 0 )
        onesymbol_time = fftin(:, ...
        (params.RxSampleperSymbol *(symbol-1)+idx:params.RxSampleperSymbol *symbol) ...
        );           
        [onesymbol,sig_pwr, noise_pwr ]  = FFTnRemoveCP( onesymbol_time, H, params, sim);
	else
	    iindex = params.RxSampleperSymbol *(symbol-1.0)+idx : ...
	         params.RxSampleperSymbol *(symbol+0.0) ;
	    qindex = params.RxSampleperSymbol *(symbol-0.5)+idx : ...
	         params.RxSampleperSymbol *(symbol+0.5) ;
            [onesymbol_re,sig_pwr, noise_pwr ]  = ...
                FFTnRemoveCP( fftin(:, iindex), H, params, sim);
            [onesymbol_im,sig_pwr, noise_pwr ]  = ...
                FFTnRemoveCP( fftin(:, qindex), H, params, sim);
	    onesymbol =   (real(onesymbol_re  .* (ones(d1,1) * exp( 1 * -1j* pi/2 * mod([0:params.NFFT-1],2 )))) + ...
                       (1j*real(onesymbol_im  .* (ones(d1,1) * exp( 1 * -1j* pi/2 * mod([1:params.NFFT ],2 ))))));
% 	    onesymbol = complex( real(onesymbol_re), real(onesymbol_im)) ;
	end 
        if ( symbol ~= 1 ) % Compensate Sampling clock offset & CPE 
            onesymbol = Change_fixed_bit( onesymbol, sim.DCTOutbit );  
            onesymbol = onesymbol .* exp( -1j* timingoffset(symbol-1) * ...
              ( ones(params.Nstream,1) * [(1:params.NFFT/2-1) -params.NFFT/2:0])); 
            onesymbol = Change_fixed_bit( onesymbol, sim.DCTOutbit );  
        end 
        %% CPE due to phase noise 
        if ( sim.enCPEcomp == 1 )
            pilot = onesymbol(:,params.PilotIndex ); 
            cpe = mean( pilot  .* (ones( params.Nstream, 1) * params.Pilot),2);
            delta_CPE =  Change_fixed_bit_lim(  ( angle( cpe )), sim.ATAN1bit,  pi)  ; 
            commonphase(:, symbol) = delta_CPE  ; 
%             delta_CPE = ones(1,params.Nstream) *mean(delta_CPE);
            for istream=1:params.Nstream
%                 onesymbol(istream, :) = exp( -1j*1*(delta_CPE(istream) ))*onesymbol(istream, :);
                onesymbol(istream, :) = exp( -1j*1*(delta_CPE(istream)+dfb_cpe(istream)))*onesymbol(istream, :);
            end

        end
        %% Sampling Frequency offset compensation 
        if ( sim.enSFOcomp == 1 ) 
            pilot = onesymbol(1,params.PilotIndex );
            to(symbol) =mean( angle( pilot ./params.Pilot) ./ PilotIndex );
            to(symbol) = Change_fixed_bit_lim( to(symbol), sim.ATAN2bit, pi);
            timingoffset(symbol) =to(symbol);
            if ( symbol > 3 ) 
                timingoffset(symbol) = mean(to(symbol-3:symbol) );
                onesymbol = onesymbol .* (ones(params.Nstream, 1)* exp(- 1j* timingoffset(symbol) * [(1:params.NFFT/2-1) -params.NFFT/2:0]));
                onesymbol = Change_fixed_bit( onesymbol, sim.DCTOutbit );  
            end
        end 
        
        %% DFS-spread
         if ( params.en_DFT_S == 1 )
        fftout_cur =  fft(onesymbol(:,params.SubcarrierIndex ));
         else
        fftout_cur = onesymbol(:,params.SubcarrierIndex );
         end 
        
        signal_power = signal_power + sig_pwr;
        noise_power = noise_power + noise_pwr;
        
        %% Phase rotation using decision feedback 
        if ( sim.decision_feedback_cpe == 1 )
            demapperout = NRxDemapper( params.en_bitalloc ,  fftout_cur, params );
            rxidealout     = NMapper( demapperout,  params );
            ang_diff =mod(angle(fftout_cur) -angle(rxidealout)+pi, 2*pi)-pi ;
            %             if ( symbol < 4 )
            dfb_cpe =  dfb_cpe + 0.5*( mean(ang_diff,2) );
            %             end
            ttt =[ ttt dfb_cpe];
            fftout_cur = fftout_cur .* (exp(-1j*mean(ang_diff,2) ) * ones(1, size(params.SubcarrierIndex,2 )));
        end
        %         plot(onesymbol(:,params.SubcarrierIndex ) .* (exp(-1j*dfb_cpe) * ones(1, size(params.SubcarrierIndex,2 ))),'r*');
        fftout =  [fftout, fftout_cur];
    end 
    
    snr = signal_power ./ noise_power;
end 



