function transmitout   = IFFTnAddCP_PreComp( transmitin, params, sim );

    [d1, d2 ] = size( transmitin );
    i= sqrt(-1);
    %% definitions of parameters
    if ( params.OVERSAMPLE  ~= 1 )
        error('Oversampling is not verified in IFFTnAddCP_PreComp.m')
    end
%     if ( d1  ~= 1 )
%         error('One stream for each IFFTnAddCP_PreComp.m')
%     end
    oversample = 1 ;
    nFFTSize = params.NFFT ;
    CPratio = params.CPratio ;
    NumSymbol = params.NSymbol ;
    num_tone =  length(params.SubcarrierIndex) + length(params.Pilot); 
    if (sim.subband == 0 )
        out_d1 =1;
        transmitout = zeros( out_d1, NumSymbol * (1+CPratio) * oversample*nFFTSize   ) ;
    else
        if (sim.precomp_en == 2 )
            out_d1 =sim.subband;%params.NFFT* d1;
            transmitout = zeros( out_d1, NumSymbol * (1+CPratio) * oversample*nFFTSize /sim.subband ) ;
        end
        if (sim.precomp_en == 1 )
            out_d1 = nFFTSize * d1;
            transmitout = zeros( out_d1, NumSymbol * (1+CPratio) * oversample*nFFTSize  ) ;
        end
        if (sim.precomp_en == 3 )
            out_d1 = sim.subband;
            transmitout = zeros( out_d1, NumSymbol * (1+CPratio) * oversample*nFFTSize /sim.subband ) ;
        end
    end
     
    NumCP= floor(nFFTSize/2*oversample*CPratio+0.5)*2;
    CPIndex = [nFFTSize*oversample-NumCP+1:nFFTSize*oversample];
%     phasor =  params.phi* ([0:params.NFFT/2-1 -params.NFFT/2:-1]) .^2 ;
    zeropad = zeros(params.NFFT/4,1);
    
    %% IFFT for each symbol
   
    OneSymbol = reshape( transmitin(1,:), nFFTSize, NumSymbol );    
    NAddedSamples= nFFTSize *(oversample-1) ;
    for k=1:NumSymbol     
        OneSymbol = (transmitin(:, ((k-1)*nFFTSize +1:k*nFFTSize) ));
        OverSymbol = ([ OneSymbol , zeros(d1,NAddedSamples)]);
        if (d1==1)
            ifftout = ifft_band( (OverSymbol(1,:) ), params, sim);
        else
             ifftout = [ ifft_band( (OverSymbol(1,:) ), params, sim) ; ...
                           ifft_band( (OverSymbol(2,:) ), params, sim) ; ];
        end        
%         ifftout = circshift( ifftout, [0, params.CPshift]) ;
        if ( sim.precomp_en == 2 || sim.precomp_en == 3 )            
            guardout = circshift(  [ifftout(:,params.CPIndex), ifftout] , [0, params.CPshift])  ;
            transmitout(:, ((k-1)*nFFTSize/sim.subband1*oversample*(1+CPratio) +1:k*nFFTSize/sim.subband1*oversample*(1+CPratio))) = guardout;              
         else                         
            guardout = circshift(  [ifftout(:,params.CPIndex), ifftout] , [0, params.CPshift]); 
            transmitout(:, ((k-1)*nFFTSize*oversample*(1+CPratio) +1:k*nFFTSize*oversample*(1+CPratio))) = guardout;       
           end
    end

    transmitout = 1/sqrt( num_tone) *transmitout;
end
 
 

    
    

    
