function [demapper_out]  = ...
                       NRxDemapper_sc( demapper_in,  params )
                
Nbpsc = params.Nbpsc_sc;
[d1, d2 ] = size ( demapper_in );

num_demap = params.Nsd * params.NSymbol;% d2 * Nbpsc ;
demapper_out = zeros( 1, d1 * num_demap );

% Pilot power(1) : data power = norm_factor ( pilot power ) : norm_factor 
% norm_factor = norm_factor * data power/Pilot power
% norm_factor = norm_factor * 1/sqrt(10)

norm_factor = [ 1, 1, 1, 1/sqrt(10), 1,  1/sqrt(42)];
MAX_V       = [ 1, 1, 1, 3, 1, 7];

demapper_tmp =zeros(d1, params.Nsd*params.NSymbol);


norm_factor_sc = norm_factor(Nbpsc);
MAX_V_sc = MAX_V(Nbpsc);


for iNtx=1:d1
    for nsymbol=1:params.NSymbol
         demapper_tmp1 ...
         = floor(real(demapper_in(iNtx,(nsymbol-1)*params.Nsd+1:(nsymbol)*params.Nsd)./norm_factor_sc)*0.5)*2+1  + ... 
      1j *(floor(imag(demapper_in(iNtx,(nsymbol-1)*params.Nsd+1:(nsymbol)*params.Nsd)./norm_factor_sc)*0.5)*2+1 ) ;
        demapper_tmp(iNtx,(nsymbol-1)*params.Nsd+1:(nsymbol)*params.Nsd) = ...
                max( -MAX_V_sc, min( MAX_V_sc , real(demapper_tmp1))) + ...
          1j *  max( -MAX_V_sc, min( MAX_V_sc  , imag(demapper_tmp1))) ;
    end
end
    
% if ( Nbpsc ==  3 )
    MAX_V = 2 ;
    mapper3_list = [2, 1+1j, 2j, 1-1j, -2, -1-1j, -2j, -1+1j];
    demap3_list = [ 0, 0, 0; 0, 0, 1; 0, 1, 0; 0,1,1; 1, 0, 0; 1, 0, 1; 1, 1, 0; 1,1,1;];
% end



Nbpsc_sc= params.Nbpsc;
iDemapper =1;
for iSa=1:d2
    for iNtx=1:d1
        
            sc = mod ( iSa-1, params.Nsd)+1;               
            Nbpsc_sc = Nbpsc(sc) ;
        
        if ( Nbpsc_sc ==  1 ) % BPSCK 
%             demapper_out( iDemapper ) = (demapper_tmp(iNtx, iSa ) + 1 )/2;
            if ( demapper_tmp(iNtx, iSa )  == -1 )
                demapper_out( iDemapper ) = 0 ;                 
            else 
                demapper_out( iDemapper ) = 1 ;                  
            end
        end
        if ( Nbpsc_sc ==  2 ) % QPSCK 
%             demapper_out( iDemapper  ) = (real(demapper_tmp(iNtx, iSa )) + 1 )/2;
%             demapper_out( iDemapper+1) = (imag(demapper_tmp(iNtx, iSa )) + 1 )/2;
            if ( real( demapper_tmp(iNtx, iSa ) ) ==  -1)  
                demapper_out( iDemapper ) = 0 ;
            else
                demapper_out( iDemapper ) = 1 ;
            end
            if ( imag( demapper_tmp(iNtx, iSa  ) ) == -1 )
                demapper_out( iDemapper+1 ) = 0 ;
            else
                demapper_out( iDemapper+1 ) = 1; 
            end
        end

        if ( Nbpsc_sc ==  3 ) % 8 QAM       
          distance = ( demapper_in(iNtx, iSa) /norm_factor(3)  - mapper3_list ).^2;
          demap_idx = find( distance == min(distance) );
          demapper_out( iDemapper ) = demap3_list(demap_idx,1);%mod ( demap_tmp, 2 );
          demapper_out( iDemapper+1 ) =demap3_list(demap_idx,2); %mod ( demap_tmp, 4 ) >= 2 ; 
          demapper_out( iDemapper+2 ) =demap3_list(demap_idx,3); %demap_tmp  >= 4 ;
        end
        if (Nbpsc_sc==  4 ) % 16QAM            
            switch (real(demapper_tmp(iNtx, iSa ) ))
                case {-3}   
                    demapper_out(  iDemapper:iDemapper+1 ) = [0,0] ;
                case {-1}
                    demapper_out(  iDemapper:iDemapper+1 ) = [0,1] ;
                case {1}
                    demapper_out(  iDemapper:iDemapper+1 ) = [1,1] ;
                case {3}
                    demapper_out(  iDemapper:iDemapper+1 ) = [1,0] ;
                otherwise 
                    error([ 'In 16QAM not expected value' , ...
                          num2str(real(demapper_tmp(iNtx, iSa))) ]);
            end
            switch (imag(demapper_tmp (iNtx, iSa )))
                case {-3}   
                    demapper_out(  iDemapper+2:iDemapper+3 ) = [0,0] ;
                case {-1}
                    demapper_out(  iDemapper+2:iDemapper+3 ) = [0,1] ;
                case {1}
                    demapper_out(  iDemapper+2:iDemapper+3 ) = [1,1] ;
                case {3}
                    demapper_out(  iDemapper+2:iDemapper+3 ) = [1,0] ;
                otherwise 
                    error([ 'In 16QAM not expected value' , ...
                          num2str(imag(demapper_tmp(iNtx, iSa))) ]);
            end
        end

        if ( Nbpsc_sc ==  6 ) % 64QAM 
            switch (real(demapper_tmp(iNtx, iSa )))
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
            switch (imag(demapper_tmp(iNtx, iSa )))
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
        iDemapper = iDemapper + Nbpsc(sc);
    end
    
end

