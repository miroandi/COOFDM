

function out   = ifft_band( in_flat , params, sim )
      in = in_flat ;
      
    if ( sim.preemphasis_H_en == 1 )
        H_ISFA = dlmread('..\H_files\H98_OB2B_digfilter_tx5000.txt');
        H = ones( size(in_flat));
        H( :, params.LTFindex ) = abs(H_ISFA( :, params.LTFindex )) ;
        in = in_flat .* H ;
        power_eq = sum(sum( abs(in_flat) .^ 2)) /sum(sum( abs(in ) .^ 2)) ;
        in = in * sqrt(power_eq);
    end

    if ( sim.subband == 0 )
        out = ifft(in);        
        out =  Change_fixed_bit_lim( out, sim.fftout , sim.fft_max  );
        out = [out(:,params.CPIndex), out];
    else
        
        filtercoeff =[-2.7031   36.4243   81.3764  117.0268  130.5497  116.9563   81.2784   36.3585   -2.6966];
           filtercoeff =[ -14.3570 -26.8960 -24.7813   ...
         -2.7031   36.4243   81.3764  117.0268  130.5497  116.9563   81.2784   36.3585   -2.6966  -24.7813  -26.8960  -14.3570];
        in_OFDE = zeros(1,params.NOFDE+size(filtercoeff,2)-1);
        filter_center =(size(filtercoeff,2)+1)/2-1+4;
        Ne=params.NOFDE/2-params.NFFT*(1+params.CPratio)/2;
        for ii=1:(size(filtercoeff,2) )
            in_OFDE(ii-1+(1:params.NFFT)*params.NOFDE/params.NFFT) = ...
                in_OFDE(ii-1+(1:params.NFFT)*params.NOFDE/params.NFFT)  + ...
                in *filtercoeff(ii) ;
            out1 = fftshift(ifft(in_OFDE(filter_center:filter_center+params.NOFDE-1)));   
            out=out1(Ne+1:Ne+params.NFFT*(1+params.CPratio))/116;
            out =  Change_fixed_bit_lim( out, sim.fftout , sim.fft_max  );
        end
        
    end
end

