function out       = NPrecompCD_ver2(in1, in2, sim, params, fiber)

    delay = sim.delay ; 
    [d1, d2] =size(in1);
    d2 = d2 + size( in2,2);
    zeropad = sim.zeropad ;%+ ceil(d2/sim.subband) * sim.subband -d2; 

    out = zeros( 1 ,  d2 * sim.subband1 + zeropad) ;
    
    %% TO after OFDE 
    for ii1=1:sim.subband
        out1 = zeros( 1 ,  d2+ zeropad) ; 
        out1 = [in1(ii1,:) , in2(ii1,:), zeros(1,ceil(zeropad/sim.subband1)) ];
        out4=circshift(out1,[0, round(delay(ii1)/2)]);
        if ( sim.subband == 2)
        out2 = TXOFDE(out1 , fiber, params, sim,  2 ,   ii1 -1);
        else
        out2 = TXOFDE4(out1 , fiber, params, sim,  2 ,   ii1 -1);
        end
%         out3 =  out2;
        out3 =   circshift(out2,[0, delay(ii1)]) ; 
        out = out +  out3 ; 
    end 
% out=out;
    
end 


function [ out, phase ] = TXOFDE(in, fiber, params, sim, Overlap, Freqshift )
    [d1, d2] = size( in);
         
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ;       
    MaxFreq = 1/params.SampleTime;
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/params.NOFDE);
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 

    freq_shift = []; 
    phase_shift =[];
     middle_sc = round ( params.NFFT/2 / (sim.subband /2));
    delay_idx  = [ 0:sim.subband/2-1 -sim.subband/2:-1] * middle_sc  + middle_sc/2; 
    for ii=1:sim.subband
        freq_shift = [freq_shift ...
            coef * sim.delay(ii) * ones(1, params.NOFDE/sim.subband) * 2 ]; 
    end
    
    delay_sc = [ (0:params.NOFDE/2-1) (-params.NOFDE/2:-1)]-freq_shift ; 
    delay_sc = 2*pi * MaxFreq/params.NOFDE * delay_sc ;
    tmp = - ( w .* w ) + ( w .* freq_shift * 2* pi * MaxFreq/params.NOFDE );
    DHat = 1/2*fiber.Beta2 *( (tmp)  ) * sim.FiberLength  ;
    
    FFTPoint = params.NOFDE/Overlap/sim.subband;

    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in = [zeros( d1, params.NOFDE/sim.subband), in, zeros( d1, pad)];    
    
        
    out1 = overlap_fft( in, ceil( (d2+ params.NOFDE/sim.subband)/FFTPoint), FFTPoint, 1j*DHat, Overlap, Freqshift, sim); 

    cutting = (Overlap-1) * FFTPoint;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE-cutting+(d2)*sim.subband);
    phase =   DHat;
end

function [ out, phase ] = TXOFDE4(in, fiber, params, sim, Overlap, Freqshift )
    [d1, d2] = size( in);
         
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ;       
    MaxFreq = 1/params.SampleTime;
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/params.NOFDE);
    o=1;%sim.subband1;
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 

     if ( sim.subband == 4)
        m =params.NOFDE/params.NFFT;
        
        freq_shift =  ones(1,params.NFFT*m) *  round(sim.delay(Freqshift+1)/o)*o;
        freq_shift = coef * freq_shift * 2;
     end
    
     if ( sim.subband == 8)
        m =params.NOFDE/params.NFFT;
        
%         freq_shift(1,:) =  [ ones(1,64*m) * sim.delay(1), ones(1,64*m) * sim.delay(5)];
%         freq_shift(2,:) =  [ ones(1,64*m) * sim.delay(2), ones(1,64*m) * sim.delay(6)];
%         freq_shift(3,:) =  [ ones(1,64*m) * sim.delay(3), ones(1,64*m) * sim.delay(7)];
%         freq_shift(4,:) =  [ ones(1,64*m) * sim.delay(4), ones(1,64*m) * sim.delay(8)];
       
        freq_shift =  ones(1,params.NFFT*m) *round(sim.delay(Freqshift+1)/o)*o;
        freq_shift = coef * freq_shift * 2;
    end
    
    
    delay_sc = [ (0:params.NOFDE/2-1) (-params.NOFDE/2:-1)]-freq_shift  ; 
    delay_sc = 2*pi * MaxFreq/params.NOFDE * delay_sc ;
    tmp = - ( w .* w ) + ( w .* freq_shift  * 2* pi * MaxFreq/params.NOFDE );
    DHat = 1/2*fiber.Beta2 *( (tmp)  ) * sim.FiberLength  ;
    
    FFTPoint = params.NOFDE/Overlap/sim.subband1;

    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in = [zeros( d1, params.NOFDE/sim.subband1), in, zeros( d1, pad)];    
    
        
    out1 = overlap_fft( in, ceil( (d2+ params.NOFDE/sim.subband1)/FFTPoint), FFTPoint, 1j*DHat, Overlap, Freqshift, sim); 

    cutting = (Overlap-1) * params.NOFDE/4;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE-cutting+(d2)*sim.subband1);
    phase =   DHat;
end


     
function out = overlap_fft( in_time, fftnum, fftsize,  DHat, Overlap, Freqshift,sim )
     dispersion_op = ones( size(in_time,1),1) * exp(DHat);
     IFFTov = sim.subband1;
     IFFTSize = fftsize*IFFTov;
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
         
        BFreq = [ AFreq, zeros(1,fftsize*Overlap*(IFFTov-1))];
        CFreq = circshift(BFreq,[0,   floor( 2*Freqshift/sim.subband) * fftsize * Overlap ]) ;          
        BTime = ifft (dispersion_op  .* CFreq, [], 2 );
        
%         BTime = ifft( CFreq , [], 2 );
        cutting = (Overlap-1) * IFFTSize/2;
        ATime( :, (fftstep-1)*IFFTSize+1:(fftstep)*IFFTSize) = BTime(:,cutting+1:cutting+IFFTSize) ;
    end
    out = ATime;
end


