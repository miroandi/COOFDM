function [demapper_out]  =  NRxDemapper_simple( demapper_in, params ) 
                
Nbpsc = params.Nbpsc;
[d1, d2 ] = size ( demapper_in );
j = sqrt(-1);


% Pilot power(1) : data power = norm_factor ( pilot power ) : norm_factor 
% norm_factor = norm_factor * data power/Pilot power
% norm_factor = norm_factor * 1/sqrt(10)

norm_factor =1;
if ( Nbpsc ==  3 ) 
    norm_factor = norm_factor /sqrt(3) ;
end 
if ( Nbpsc ==  4 ) 
    norm_factor = norm_factor /sqrt(10) ;
end 
if ( Nbpsc ==  6 ) 
    norm_factor = norm_factor /sqrt(42);
end 

if ( Nbpsc ==  3 )
    MAX_V = 2 ;
    mapper_list = [2 1+1j 2j 1-1j -2 -1-1j -2j -1+1j];
    demap_list = [ 0, 0, 0; 1, 0, 0; 0, 1, 0; 1,1,0; 0, 0, 1; 1, 0, 1; 0, 1, 1; 1,1,1;];
end
if ( Nbpsc ==  4 )
    MAX_V = 3 ;
    mapper_list = [ 1+1j,  1+3j, 3+1j, 3+3j, 1-1j,  1-3j, 3-1j, 3-3j, ... 
       - 1+1j,  -1+3j, -3+1j, -3+3j, -1-1j,  -1-3j, -3-1j, -3-3j ];
        
end
if ( Nbpsc ==  6 )
    MAX_V = 7 ;
end
% Demapping 
if ( Nbpsc ==  1 ) % BPSK 
    demapper_tmp = sign(real(demapper_in)) ;
else
    if ( Nbpsc ==  2 ) % QPSK
        demapper_tmp = sign(real(demapper_in)) + ...
                       j*sign(imag(demapper_in)) ;
    else         
        demapper_tmp1 = floor(real(demapper_in)/norm_factor*0.5)*2+1  + ... 
                   j *(floor(imag(demapper_in)/norm_factor*0.5)*2+1 ) ;
       
        demapper_tmp = max( -MAX_V, min( MAX_V , real(demapper_tmp1))) + ...
                  j *  max( -MAX_V, min( MAX_V , imag(demapper_tmp1)))  ;
    end
end

num_demap = d2 * Nbpsc ;
demapper_out = zeros( 1, d1 * num_demap );

%% BPSCK
if ( Nbpsc ==  1 ) 
    demapper_out1 = round((demapper_tmp  + 1)/2 );
    demapper_out = reshape (demapper_out1, 1, size(demapper_out1,1)*size(demapper_out1,2));
end

%% QPSK
if ( Nbpsc ==  2 ) 
    demapper_out1 = round( (demapper_tmp + 1 +1j)/2 );
    demapper_out2 = reshape (demapper_out1, 1, size(demapper_out1,1)*size(demapper_out1,2));
    demapper_out(1:2:size(demapper_out2,2)*2) = real( demapper_out2);
    demapper_out(2:2:size(demapper_out2,2)*2) = imag( demapper_out2);
end
  
%% 16 QAM 
if ( Nbpsc ==  4 ) % 16QAM 
    demapper_out2 = reshape (demapper_tmp, 1, size(demapper_tmp,1)*size(demapper_tmp,2));
    demapper_out(2:4: d1 * num_demap) = mod( (abs(real(demapper_out2)) + 1)/2, 2);
    demapper_out(1:4: d1 * num_demap) = (real(demapper_out2) > 0 );
    demapper_out(4:4: d1 * num_demap) = mod( (abs(imag(demapper_out2)) + 1 )/2, 2);
    demapper_out(3:4: d1 * num_demap) = (imag(demapper_out2) > 0 );
end

for iSa=1:d2
    for iNtx=1:d1
		iDemapper = d1 * Nbpsc * ( iSa   - 1 ) + Nbpsc *(iNtx-1) +1 ; 
	
        %% 8 QAM 
        if ( Nbpsc ==  3 ) % 8 QAM       
            distance = ( demapper_in(iNtx, iSa)/norm_factor  - mapper_list ).^2;
            demap_idx = find( distance == min(distance) );
            demapper_out( iDemapper ) = demap_list(demap_idx,1);%mod ( demap_tmp, 2 );
            demapper_out( iDemapper+1 ) =demap_list(demap_idx,2); %mod ( demap_tmp, 4 ) >= 2 ; 
            demapper_out( iDemapper+2 ) =demap_list(demap_idx,3); %demap_tmp  >= 4 ;
        end
        
        %% 64 QAM 
        if ( Nbpsc ==  6 ) % 64QAM 
            switch (real(demapper_tmp(iNtx, iSa)))
                case {-7} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,0,0] ;
                case {-6} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,0,0.5] ;
                case {-5} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,0,1] ;
                case {-4} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,0.5,1] ;
                case {-3} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,1,1] ;
                case {-2} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,1,0.5] ;
                case {-1} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0,1,0] ;
                case {0} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [0.5,1,0] ;
                case {1} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,1,0] ;
                case {2} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,1,0.5] ;
                case {3} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,1,1] ;
                case {4} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,0.5,1] ;
                case {5} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,0,1] ;
                case {6} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,0,0.5] ;
                case {7} 
                    demapper_out(  iDemapper:iDemapper+2 ) = [1,0,0] ;
                otherwise 
                    error([ 'In 64 QAM not expected value' , ...
                          num2str(real(demapper_tmp(iNtx, iSa))) ]);
            end
            switch (imag(demapper_tmp(iNtx, iSa)))
                case {-7} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,0,0] ;
                case {-6} 
                    demapper_out(  iDemapper+3:iDemapper+5) = [0,0,0.5] ;
                case {-5} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,0,1] ;
                case {-4} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,0.5,1] ;
                case {-3} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,1,1] ;
                case {-2} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,1,0.5] ;
                case {-1} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0,1,0] ;
                case {0} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [0.5,1,0] ;
                case {1} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,1,0] ;
                case {2} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,1,0.5] ;
                case {3} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,1,1] ;
                case {4} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,0.5,1] ;
                case {5} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,0,1] ;
                case {6} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,0,0.5] ;
                case {7} 
                    demapper_out(  iDemapper+3:iDemapper+5 ) = [1,0,0] ;
                otherwise 
                    error([ 'In 64 QAM not expected value' , ...
                          num2str(imag(demapper_tmp(iNtx, iSa))) ]);
            end
        end
    end
end

