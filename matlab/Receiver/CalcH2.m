function H = CalcH2( LTF_t, LTF2_t, sim, params)
     LTF = (fft( LTF_t, [],2) );
        LTF = Change_fixed_bit( LTF, sim.FFTOutbit ); 
        LTF2 = (fft( LTF2_t, [],2) );
        LTF2 = Change_fixed_bit( LTF2, sim.FFTOutbit ); 

    Response(1,:,:) = LTF(:, 1:params.NFFT ) .* [ params.LTF; params.LTF]  ;
    Response(2,:,:) = LTF2(:, 1:params.NFFT ) .* [ params.LTF; params.LTF]   ;
    H = zeros( 2, params.Nstream, params.NFFT);
    if ( params.Nstream == 1 )
        for ii=1:(length(params.LTFindexE))
            idx=params.LTFindexE(ii);
            H(:,1, idx) = ctranspose(Response(1,:,idx)) ...
                      / ( Response(1,:,idx) *ctranspose(Response(1,:,idx)));
        end
    else                
        for ii=1:(length(params.LTFindexE))
            H(:,:,params.LTFindexE(ii)) =inv(Response(:,:,params.LTFindexE(ii)));
        end
    end 
end