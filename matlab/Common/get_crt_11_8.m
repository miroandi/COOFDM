function [out, int_16, int_9] = get_crt_11_8( int_16, int_9 );;


    
    mx1 = 11 ;mx2 =8;
   a1 =56;a2=-55; 
    M=mx1*mx2;
    if ( int_16 == 4 ) int_16 = -4 ;end 
 
	out =mod((a1 * mod ( int_9 , mx1) + a2 * mod ( int_16, mx2)) ,M);
    out = mod((out + M/2 ), M)-M/2;
% 	if ( out > 71 ) out =out-144 ;end 
end
