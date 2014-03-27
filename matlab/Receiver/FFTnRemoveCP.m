%%
function [fftout,sig_pwr, noise_pwr ]  = FFTnRemoveCP( fftin, H, params, sim)

    onesymbol_freq =fft(fftin, [],2); 
    onesymbol_freq = Change_fixed_bit( onesymbol_freq, sim.FFTOutbit ); 
    onesymbol_freq1 = onesymbol_freq(:,params.RXFFTidx);
    %% ESNR measurement
    for istream=1:size(fftin, 1)
        tot_pwr(istream) =  sum(abs(onesymbol_freq1(istream,:)) .^ 2) ;
        sig_pwr(istream) = sum(abs(onesymbol_freq1(istream,params.LTFindex)) .^ 2);
    end
    noise_pwr =  (tot_pwr-sig_pwr ) ;
    %% Channel equalization 
    if ( size(fftin,1) == 1 )
        onesymbol = (onesymbol_freq(:,params.RXFFTidx)).* H ;
    else
        for ii=1:params.NFFT
            onesymbol(:,ii) =[ onesymbol_freq(1,ii)  onesymbol_freq(2,ii)] * H(:,:,ii);
        end
    end

    fftout = Change_fixed_bit( onesymbol, sim.DCTOutbit  );  
end