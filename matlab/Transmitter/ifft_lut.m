
function out   = ifft_lut( in , sim );
    fftsize = length(in);
    
%     temp = zeros( fftsize, fftsize);
    out1 = zeros( fftsize, fftsize);
    for isize=1:fftsize
%         temp( :, isize) = (isize-1) *(0:fftsize-1);
        out1( :, isize ) =  in .*   exp(  1i*2*pi/fftsize * (isize-1) *(0:fftsize-1))/fftsize ;
    end
%     temp =  1i*2*pi/fftsize * temp;
%     out = in * exp( temp ) / fftsize ;
    
    
    lut_out = Change_fixed_bit_lim( out1, sim.lut_bit , sim.lut_max  );
    out =  Change_fixed_bit_lim( sum(lut_out) , sim.fftout , sim.fft_max  );
end