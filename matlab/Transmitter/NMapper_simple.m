function mapperout = NMapper_simple ( mapperin,  params );

d2 = length ( mapperin );
j=sqrt(-1);
Nbpsc = params.Nbpsc;

% if ( mod (d2,  Nbpsc) == 0 ) 
% 	num_map =  d2/Nbpsc ;
% else
% 	error( 'Mapper input has wrong length ');
% end

num_map =  d2/Nbpsc/params.Nstream  ;

%disp(['NMapper: Nbpsc',num2str(Nbpsc)])

mapperout = zeros( params.Nstream, num_map );

if ( Nbpsc ==  1 ) % BPSCK 
    mapperout1 = mapperin * 2 -1 ;
    mapperout=reshape( mapperout1, params.Nstream, size(mapperout1,2)/params.Nstream);
end

if ( Nbpsc ==  2 ) % QPSK 
    mapperout1 = mapperin( 1:2:size(mapperin,2)) * 2 - 1 + ...
            1j*(mapperin( 2:2:size(mapperin,2)) * 2 - 1 );
    mapperout=reshape( mapperout1, params.Nstream, size(mapperout1,2)/params.Nstream);
end 


if ( Nbpsc ==  3 ) % QPSK 
    mapperout_0 = mapperin( 1:3:size(mapperin,2));
    mapperout_1 = mapperin( 2:3:size(mapperin,2));
    mapperout_2 = mapperin( 3:3:size(mapperin,2));
    mapperout1 =  2*exp( 1j * pi/2 *(mapperout_2*2+mapperout_1)) .* ( 1- mapperout_0 ) + ...
                  sqrt(2)*exp( -1j * pi/2 *(mapperout_1+mapperout_2*2) + 1j*pi/4) .* (mapperout_0 );
    mapperout=reshape( mapperout1, params.Nstream, size(mapperout1,2)/params.Nstream); 
			
end 


if ( Nbpsc ==  4 ) % 16QAM 
    mapperout1 = ...
      ( mapperin( 1:4:size(mapperin,2)) * 2 +mapperin( 2:4:size(mapperin,2))) + ...
   1j*( mapperin( 3:4:size(mapperin,2)) * 2 +mapperin( 4:4:size(mapperin,2))) ;
  
    mapperout1_re = mapperin( 1:4:size(mapperin,2)) * 2 +mapperin( 2:4:size(mapperin,2));
    mapperout1_im = mapperin( 3:4:size(mapperin,2)) * 2 +mapperin( 4:4:size(mapperin,2));
    mappout2 = (1-2* ( (mapperout1_re) < 2 )) .* ( mod ( mapperout1_re+1, 2) *2 + 1 ) + ...
     +1j*((1-2* ( (mapperout1_im) < 2 )) .* ( mod ( mapperout1_im+1, 2) *2 + 1 ));
    mapperout=reshape( mappout2, params.Nstream, size(mappout2,2)/params.Nstream);
end 
	

if ( Nbpsc ==  6 ) % 64QAM 
    for d1=0:params.Nstream-1
        for k=d1*num_map+1:d1*num_map+num_map
            % Grey Coding 0 -> 1 -> 3 -> 2 -> 6 -> 7 -> 5 -> 4 
            datatmp = mapperin( 6*k -5 )*4 + mapperin( 6*k -4) *2 + ...
                      mapperin( 6*k -3 ) ;
            switch datatmp
                case {0} 
                     mapperout( k ) = -7 ;
                case {1} 
                      mapperout( k ) = -5 ;
                case {3} 
                      mapperout( k ) = -3 ;
                case {2} 
                      mapperout( k ) = -1 ;
                case {6} 
                      mapperout( k ) =  1 ;
                case {7} 
                      mapperout( k ) =  3 ;
                case {5} 
                      mapperout( k ) =  5 ;
                case {4} 
                      mapperout( k ) =  7 ;
            end
            datatmp = mapperin( 6*k -2 )*4 + mapperin( 6*k -1) *2 + ...
                      mapperin( 6*k    ) ;
            switch datatmp
                case {0} 
                      mapperout( k ) = mapperout(k) -7*j ;
                case {1} 
                      mapperout( k ) = mapperout(k) -5*j ;
                case {3} 
                      mapperout( k ) = mapperout(k) -3*j  ;
                case {2} 
                      mapperout( k ) = mapperout(k) -1*j  ;
                case {6} 
                      mapperout( k ) = mapperout(k) +1*j ;
                case {7} 
                      mapperout( k ) = mapperout(k) +3*j ;
                case {5} 
                      mapperout( k ) = mapperout(k) +5*j  ;
                case {4} 
                      mapperout( k ) = mapperout(k) +7*j  ;
            end
        end
    end
end 
	


if ( Nbpsc ==  2 ) % QPSCK 
	mapperout = 1/sqrt(2) * mapperout;
end
if ( Nbpsc ==  3 ) % 8 QAM 
	mapperout = 1/sqrt(3)  * mapperout;
end
if ( Nbpsc ==  4 ) % 16QAM 
	mapperout = 1/sqrt(10) * mapperout;
end

if ( Nbpsc ==  6 ) % 64QAM 
	mapperout = 1/sqrt(42) * mapperout;
end

