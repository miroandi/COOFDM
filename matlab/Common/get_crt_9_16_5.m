function [out,  int_9, int_16,int_5 ] = get_crt_9_16_5(  int_9 ,int_16, int_5 );;

% a1 = ( 1/(16*5) mod 9 )*16*5 ; -80, 640
% a2 = ( 1/(9*5) mod 16 )*9*5 ;-495,  225
% a3 = ( 1/(16*9) mod 5 )* 16*9 ; -144 ,576

a1 =-80;
a2 =225;  
a3=-144;
    if ( int_16 == 8 ) int_16 = -8 ;end

	out =mod((a1 * mod ( int_9 , 9) + a2 * mod ( int_16, 16)+ a3 * mod ( int_5, 5)) ,9*16*5);
    out = mod((out + 9*16*5/2 ), 9*16*5)-9*16*5/2;
% 	if ( out > 71 ) out =out-144 ;end 
end

% 1. Get a1, a2, a3 ... 
% inv = 8;
% m=9
% for int=-inv:inv
%   d = mod( inv*int , m );
%   if ( d == 1 )      
%       a = int * inv
%   end
% end 

 
% 2. Choose propoer values 

% 3. Check 
% M = 9*8;%9*16 *5
% m1 = 9 ; m2 =8 ;  m3 = 5;
% a1 =-8;
% a2 =9;  a3=-144;
% for int=0:(M-1)
%    crt = a1 * mod ( int, m1) + a2 * mod( int, m2 );%+ a3 * mod( int, m3);
%    if ( int ~= mod(crt, M) )
%        disp('Error');
%        int
%        crt
%     end
% end 