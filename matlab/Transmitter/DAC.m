function AOUT =  DAC( AIN, BIT, LIM )
    if ( BIT <= 0 )
        AOUT = AIN ;
    else
        % from -(2^(BIT-1)-1) to (2^(BIT-1)-1)
        AOUTR = floor((real(AIN)/LIM) *(2^(BIT-1)-1)+0.5) ;
        AOUTI = floor((imag(AIN)/LIM) *(2^(BIT-1)-1)+0.5) ;
        AOUT = complex( min(abs(2^(BIT-1)-1), max(-abs(2^(BIT-1)-1), AOUTR )), ...
             min(abs(2^(BIT-1)-1), max(-abs(2^(BIT-1)-1), AOUTI )));
    end
    
end 