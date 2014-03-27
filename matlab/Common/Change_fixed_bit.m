function AOUT = Change_fixed_bit( AIN, BIT);

    if ( BIT <= 0 )
        AOUT = AIN ;
    else
        LIM=  max(max([ real(AIN)  imag(AIN) ]));
        AOUTR = floor((real(AIN)/LIM) *(2^(BIT-1)-1)+0.5)*LIM/(2^(BIT-1)-1) ;
        AOUTI = floor((imag(AIN)/LIM) *(2^(BIT-1)-1)+0.5)*LIM/(2^(BIT-1)-1) ;
        AOUT = complex( min(abs(LIM), max(-abs(LIM), AOUTR )), ...
             min(abs(LIM), max(-abs(LIM), AOUTI )));
    end
    
end