

function out   = ifft_band_Precomp( in_flat , params, sim )
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
    else
        if ( sim.precomp_en == 1 )

            fftsize = params.NFFT * params.OVERSAMPLE;  
            out1 = zeros( fftsize, fftsize);
            for isize=1:fftsize
                out1( :, isize ) =  in .*   exp(  1i*2*pi/fftsize * (isize-1) *(0:fftsize-1))/fftsize ;
            end

            lut_out = Change_fixed_bit_lim( out1, sim.lut_bit , sim.lut_max  );
            out =  Change_fixed_bit_lim( (lut_out) , sim.fftout , sim.fft_max  );

        end
        if ( sim.precomp_en == 2 || sim.precomp_en == 3)
            fftsize = params.NFFT * params.OVERSAMPLE;  
            mul = params.NFFT/128;
            if ( sim.subband > 2  && sim.subband1 <= 2 )
                tt = 64 *(2-sim.subband1);
                out( 1, :) =   ifft( [in(1:28*mul), zeros(1,(4+32+tt)*mul )]);  
                out( 2, :) = 1*  ifft( [zeros(1, 28*mul), in((28*mul+1):(56*mul) ),zeros(1,(8+tt)*mul)]);  
                
                out( 3, :) = 1*  ifft( [zeros(1,(9+tt)*mul),in((73*mul+1):(101*mul)),zeros(1, 27*mul) ]);  
                out( 4, :) = 1*  ifft( [zeros(1, (32+5+tt)*mul), in((101*mul+1):128*mul)]);  
            else
                
                for ii=1:sim.subband 
                out( ii, :) =  ifft( in(fftsize/sim.subband*(ii-1)+1:fftsize/sim.subband*(ii)) );  
                end
            end
            if ( sim.subband >2  && sim.subband1 == 4)
                out( 1, :) = 1*  ifft( [in(1:28), zeros(1,4  )]);  
                out( 2, :) = 1*  ifft( [zeros(1, 4), in(29:56 ) ]);  
                
                out( 3, :) =1*   ifft( [zeros(1,4),in(128-54:128-27)  ]);  
                out( 4, :) = 1*   ifft( [zeros(1, 5), in(128-26:128)]);  
            end
             if ( sim.subband == 8   && sim.subband1 == 2)
                out( 1, :) =    ifft( [in(1:16), zeros(1,48  )]);  
                out( 2, :) =    ifft( [zeros(1, 16), in(17:28 ),zeros(1,4+32 ) ]);  
                out( 3, :) =    ifft( [zeros(1, 28), in(29:40 ),zeros(1,24)]);  
                out( 4, :) =    ifft( [zeros(1, 40), in(41:56 ),zeros(1,8) ]);  
                
                out( 5, :) =    ifft([zeros(1,9),in(74:89),zeros(1, 39) ]);  
                out( 6, :) =    ifft( [zeros(1,25),in(90:101),zeros(1, 27) ]);  
                out( 7, :) =    ifft([zeros(1, 32+5), in(102:113),zeros(1,15) ]);  
                out( 8, :) =    ifft( [zeros(1, 32+5+12), in(114:128) ]);  
            end

            out =  Change_fixed_bit_lim( (out) , sim.fftout , sim.fft_max  );
        end
        
        if ( sim.precomp_en == 4 )
            fftsize = params.NFFT * params.OVERSAMPLE;  
            out = zeros( sim.subband, fftsize);
            for ii=1:sim.subband 
                in_tmp = zeros(size(in ));
                in_tmp ( fftsize/sim.subband*(ii-1)+1:fftsize/sim.subband*(ii))= ...
                    in( fftsize/sim.subband*(ii-1)+1:fftsize/sim.subband*(ii) );
            out( ii, :) =  ifft( in_tmp );  
            end

            out =  Change_fixed_bit_lim( (out) , sim.fftout , sim.fft_max  );
        end
        
    end
end

