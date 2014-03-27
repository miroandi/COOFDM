function out       = NPrecompCD_ver4(in1, in2, sim, params, fiber)

    d2 = size( in1, 2) + size( in2, 2);
    zeropad = sim.zeropad + mod( d2,2); 

    params.cut = (2-1)*params.NOFDE /8 ;
    out3 = zeros( 1 ,  d2 + zeropad) ;
    for ii1=1:sim.subband
        out1 = [in1(ii1,:) , in2(ii1,:), zeros(1,zeropad) ];
        out2 = circshift(out1,[0, sim.delay(ii1)]) ;%* exp( -1j* sim.phase (ii1) );
        out3 = out3 +  out2 (:, 1: d2 + zeropad); 
    end 
    [ out, phase ] = OFDE(out3, fiber, params, sim, 2 );
%     out =out3;
end 


function [ out, phase ] = TxOFDE(in, fiber, params, sim, Overlap )
    OFDESize = params.NOFDE ;
    [d1, d2] = size( in);  
    MaxFreq = 1/params.SampleTime;%/sim.subband;
    coef =   -2*pi*fiber.Beta2 *sim.FiberLength /(params.SampleTime ^2 *params.NFFT ) ;
    w = [0:OFDESize/2-1, -OFDESize/2:-1 ] ; 
    w1 = w - 55 * OFDESize/params.NFFT;
    w= 2*pi * MaxFreq/OFDESize * w ;  
    w1= 2*pi * MaxFreq/OFDESize * w1 ;  
    total_DHat = w .* w1 ;
    
    delay1 = sim.delay ;%- ( sim.delay(2) )/2 ;
    delay1 = delay1 *2;
    delay_sc =[];
    for ii=1:sim.subband
    delay_sc = [ delay_sc delay1(ii) * ones( 1, OFDESize/sim.subband)]; 
    end 
  
    delay_sc = delay_sc / coef * OFDESize / params.NFFT;
    delay_sc = 2*pi * MaxFreq/OFDESize * delay_sc ;
    delay_DHat = w .* delay_sc ; 
        
    DHat = 1/2*fiber.Beta2 *( (- total_DHat - delay_DHat )  ) * sim.FiberLength  ;

    FFTPoint = OFDESize/Overlap;
    [pad, tot_length] = CalcPadNum( d2, Overlap, FFTPoint);
    in = [zeros( d1, params.cut/2), in, zeros( d1, pad-params.cut/2)];    

    out1 = overlap_fft( in,  FFTPoint, 1j*DHat, Overlap);  
    out = out1(1:d2 );
    
    phase =   DHat;
end


function [ out, phase ] = TxOFDE2(in, fiber, params, sim, Overlap )
    [d1, d2] = size( in);  
    OFDESize = params.NOFDE ;
    max_freq = max([params.SubcarrierIndex1 params.PilotIndex1]);
    min_freq = min([params.SubcarrierIndex1 params.PilotIndex1]);    
    freq_shift = (max_freq +  min_freq) *OFDESize/ params.NFFT  ;
    
    w = [0:OFDESize/2-1, -OFDESize/2:-1 ]; 
    MaxFreq = 1/params.SampleTime; 
    
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/OFDESize);
   

    if ( sim.subband > 2 )
           
        w= 2*pi * MaxFreq/OFDESize * w ; 
        
        middle_sc = round ( params.NFFT/2 / (sim.subband ));
        freq_shift = [ 0:sim.subband/2-1 -sim.subband/2:-1] * middle_sc + middle_sc/2;
        freq_shift =  middle_sc * [1 1 -1 -1];
%         freq_shift = freq_shift - params.NFFT/2 ;
        freq_shift = freq_shift *OFDESize/ params.NFFT * 1;
        
        phase_shift = params.SampleTime* sim.delay_diff  /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/OFDESize);
        
        delay_sc = [ ((0:OFDESize/4-1) -freq_shift(1)), ...
                     ((0:OFDESize/4-1) -freq_shift(2)), ...
                     ((-OFDESize/4:-1)  -freq_shift(3)), ...
                     ((-OFDESize/4:-1)  -freq_shift(4)) ]; 
                 w= 2*pi * MaxFreq/OFDESize * OFDESize/8 ; 
    delay_sc = 2*pi * MaxFreq/OFDESize * delay_sc ;
    DHat = 1/2*fiber.Beta2 *( (- delay_sc .* delay_sc  + w^2)  ) * sim.FiberLength  ;
    else
        phase_shift = coef * sim.delay_diff  ;
        delay_sc = [ ((0:OFDESize/2-1)-freq_shift-phase_shift), ...
            (-OFDESize/2:-1 )+ ( freq_shift+ 1*phase_shift )];
        w= 2*pi * MaxFreq/OFDESize * w ; 
        delay_sc = 2*pi * MaxFreq/OFDESize * delay_sc ;
        DHat = 1/2*fiber.Beta2 *( (- w .* delay_sc)  ) * sim.FiberLength  ;
    end
    

        
    FFTPoint = OFDESize/Overlap;
    [pad, tot_length] = CalcPadNum( d2, Overlap, FFTPoint);
    in = [zeros( d1, params.cut/2), in, zeros( d1, pad-params.cut/2)];    

    out1 = overlap_fft( in,  FFTPoint, 1j*DHat, Overlap);  
    out = out1(1:d2 );
    
    phase =   DHat;
end



function out = overlap_fft( in_time, fftsize,  DHat, Overlap)
    fftnum = ceil( size(in_time,2)/fftsize) -1;
    dispersion_op = ones( size(in_time,1),1) * exp(DHat);
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                        (fftstep-1+Overlap)*fftsize),[], 2); 
        BTime = ifft (dispersion_op  .* AFreq, [], 2 );
%         BTime = ifft (  AFreq, [], 2 );
        cutting = (Overlap-1) * fftsize/2;
        ATime( :, (fftstep-1)*fftsize+1:(fftstep)*fftsize) = ...
        BTime(:,cutting+1:cutting+fftsize) ;
    end
    out = ATime;
end

function out = fde_oversample_2( in_time, fftsize, Freqshift )
    fftnum = ceil( size(in_time,2)/fftsize); 
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                        (fftstep)*fftsize),[], 2); 
                    if ( Freqshift == 0 ) 
        BTime = ifft ( [AFreq, zeros(size(AFreq))], [], 2 );
                    else
        BTime = ifft ( [zeros(size(AFreq)), AFreq], [], 2 );
                    end
        ATime( :, (fftstep-1)*fftsize*2+1:(fftstep)*fftsize*2) = BTime ;
    end
    out = ATime;
end

%     out1 = overlap_fft1( params, in, ceil( tot_length/FFTPoint), FFTPoint,...
%                         1j*DHat, Overlap, Freqshift, sim.subband); 

function out = overlap_fft1( params, in_time,  fftsize,  DHat, Overlap, Freqshift, IFFTov)

    fftnum = ceil( size(in_time,2)/fftsize) -1;
     dispersion_op = ones( size(in_time,1),1) * exp(DHat);
     IFFTSize = fftsize*IFFTov;
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                    (fftstep-1+Overlap)*fftsize),[], 2); 
        CFreq =  AFreq .* dispersion_op ;

        BFreq = [ CFreq, zeros(1,fftsize*Overlap*(IFFTov-1))];
        BFreq = circshift(BFreq,[0, Freqshift * fftsize * Overlap ]) ;
        BTime = ifft( BFreq , [], 2 );
        cutting = (Overlap-1) * fftsize  ; 
        cutting= params.cut;
%                 cutting = IFFTSize/2 ; 

        ATime( :, (fftstep-1)*IFFTSize+1:(fftstep)*IFFTSize) = BTime(:,cutting+1:cutting+IFFTSize) ;
    end
    out = ATime;
end