function mapperout = NMapper_sc ( mapperin,  params );

d2 = length ( mapperin );
j=sqrt(-1);
Nbpsc  = params.Nbpsc_sc ;

% if ( mod (d2,  Nbpsc(sc)) == 0 ) 
% 	num_map =  d2/Nbpsc(sc) ;
% else
% 	error( 'Mapper input has wrong length ');
% end

% num_map =  d2/Nbpsc(sc)/params.Nstream  ;
num_map = params.Nsd * params.NSymbol;
%disp(['NMapper: Nbpsc(sc)',num2str(Nbpsc(sc))])

mapperout = zeros( params.Nstream, num_map );
data_idx =1;
for d1=0:params.Nstream-1
    for k=d1*num_map+1:d1*num_map+num_map
		datatmp = 0;
        sc = mod ( k-1, params.Nsd)+1;
		if ( Nbpsc(sc) ==  1 ) % BPSCK 
			if ( mapperin( data_idx ) == 0 )  
				mapperout( k ) = -1 ;					
			else 
				mapperout( k ) = 1 ;					
			end
		end
		if ( Nbpsc(sc) ==  2 ) % QPSK 
			if ( mapperin( data_idx ) == 0 )  
				mapperout( k ) = -1 ;					
			else 
				mapperout( k ) = 1 ;					
			end
			if ( mapperin( data_idx +1 ) == 0 )  
				mapperout( k ) = mapperout( k) - j   ;					
			else 
				mapperout( k ) = mapperout( k) + j  ;					
            end
            mapperout( k ) = 1/sqrt(2) * mapperout( k ) ;
		end

		if ( Nbpsc(sc) ==  3 ) % 8 QAM 
			datatmp = mapperin( data_idx )*4 + mapperin( data_idx +1)*2 + mapperin(data_idx +2);
			switch datatmp 
				case {0}   
					mapperout( k ) = 2  ;					
				case {1}   
					mapperout( k ) = 1 +1j;			
				case {2}   
					mapperout( k ) = 2*1j;				
				case {3}   
					mapperout( k ) = 1-1j;				
				case {4}   
					mapperout( k ) = -2;					
				case {5}   
					mapperout( k ) = -1-1j;			
				case {6}   
					mapperout( k ) = -2j;					
				case {7}   
					mapperout( k ) = -1+1j;			
			end 
            mapperout( k ) = 1/sqrt(3) * mapperout( k ) ;
		end
		if ( Nbpsc(sc) ==  4 ) % 16QAM 
			datatmp = mapperin( data_idx )*2 + mapperin( data_idx +1);
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
			datatmp = mapperin( data_idx +2 )*2 + mapperin( data_idx + 3 );
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
            mapperout( k ) = 1/sqrt(10) * mapperout( k ) ;
        end
        % Grey Coding 0 -> 1 -> 3 -> 2 -> 6 -> 7 -> 5 -> 4 
		if ( Nbpsc(sc) ==  6 ) % 64QAM 
			datatmp = mapperin( data_idx )*4 + mapperin(data_idx +1) *2 + ...
                      mapperin(data_idx+2 ) ;
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
			datatmp = mapperin( data_idx + 3 )*4 + mapperin( data_idx + 4) *2 + ...
                      mapperin( data_idx + 5 ) ;
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
             mapperout( k ) = 1/sqrt(42) * mapperout( k ) ;
        end
       
        data_idx = data_idx +  Nbpsc(sc) ;
    end
end 
		

