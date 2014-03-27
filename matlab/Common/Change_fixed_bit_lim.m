function AOUT = Change_fixed_bit_lim( AIN, BIT, LIM1 )

    if ( BIT <= 0 )
        AOUT = AIN ;
    else
        % from -(2^(BIT-1)-1) to (2^(BIT-1)-1)
        LIM=LIM1 ;
        AOUTR = floor((real(AIN)/LIM) *(2^(BIT-1)-1)+0.5)*LIM/(2^(BIT-1)-1) ;
        AOUTI = floor((imag(AIN)/LIM) *(2^(BIT-1)-1)+0.5)*LIM/(2^(BIT-1)-1) ;
        AOUT = complex( min(abs(LIM), max(-abs(LIM), AOUTR )), ...
             min(abs(LIM), max(-abs(LIM), AOUTI )));
    end
    
end