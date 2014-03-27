%%
% AIN : input data (signed )
% BIT : output bit 
% CUT : CUT bits

function AOUT = Change_fixed_bit2( AIN, BIT, CUT)

    if ( BIT <= 0 )
        AOUT = AIN ;
    else
        LIM=   2^(BIT-1)-1;
        AOUTR = floor(real(AIN)/(2^(CUT))) ;
        AOUTI = floor(imag(AIN)/(2^(CUT))) ;
        AOUT = complex( min(abs(LIM), max(-abs(LIM), AOUTR )), ...
            min(abs(LIM), max(-abs(LIM), AOUTI )));
    end
    
end