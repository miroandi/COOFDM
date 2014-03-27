function mapperout = NMapper_EVM ( mapperin,  params );

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

mapperout = zeros(params.Nstream, num_map );

for d1=0:params.Nstream-1
    for k=d1*num_map+1:d1*num_map+num_map
		datatmp = 0;
		if ( Nbpsc ==  1 ) % BPSCK 
			if ( mapperin( k ) == 0 )  
				mapperout( k ) = -1 ;					
			else 
				mapperout( k ) = 1 ;					
			end
		end
		if ( Nbpsc ==  2 ) % QPSK 
			if ( mapperin( k * 2 -1 ) == 0 )  
				mapperout( k ) = -1 ;					
			else 
				mapperout( k ) = 1 ;					
			end
			if ( mapperin( k * 2 ) == 0 )  
				mapperout( k ) = mapperout( k) - j   ;					
			else 
				mapperout( k ) = mapperout( k) + j  ;					
			end
		end
		if ( Nbpsc ==  4 ) % 16QAM 
			datatmp = mapperin( 4*k -3 )*2 + mapperin( 4*k -2);
			switch datatmp
				case {0}   
					mapperout( k ) = -3 ;
				case {1}   
					mapperout( k ) = -1 ;
				case {3}
					mapperout( k ) =  1 ;
				case {2}
				   mapperout( k ) =  3 ;
			end
			datatmp = mapperin( 4*k -1 )*2 + mapperin( 4*k );
			switch datatmp
				case {0}   
					mapperout( k ) = mapperout(k) -3*j ;
				case {1}   
					mapperout( k ) = mapperout(k) -j ;
				case {3}   
					mapperout( k ) = mapperout(k) +j  ;
				case {2}   
					mapperout( k ) = mapperout(k) +3*j  ;
			end
        end
        % Grey Coding 0 -> 1 -> 3 -> 2 -> 6 -> 7 -> 5 -> 4 
		if ( Nbpsc ==  6 ) % 64QAM 
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
	mapperout = 144/208 * mapperout;
end
if ( Nbpsc ==  4 ) % 16QAM 
	mapperout = 1/sqrt(10) * mapperout;
end
if ( Nbpsc ==  6 ) % 64QAM 
	mapperout = 1/sqrt(42) * mapperout;
end

