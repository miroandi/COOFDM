function [out, int_16, int_9] = get_crt_9_11( int_16, int_9 );;


    
    mx1 = 9 ;mx2 =11;
   a1 =55;a2=-54; 
    M=mx1*mx2;
    if ( int_16 == 4 ) int_16 = -4 ;end 
%     if ( int_16 == -6 ) int_16 = 5 ;end
%     if ( int_9 == -5 ) int_16 = 4 ;end

	out =mod((a1 * mod ( int_9 , mx1) + a2 * mod ( int_16, mx2)) ,M);
    out = mod((out + M/2 ), M)-M/2;
% 	if ( out > 71 ) out =out-144 ;end 
end
