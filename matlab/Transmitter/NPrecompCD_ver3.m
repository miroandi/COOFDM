function out       = NPrecompCD_ver3(in1, in2, sim, params, fiber)

    delay = sim.delay      ; 
    [d1, d2] =size(in1);
    d2 = d2 + size( in2,2);
    zeropad = sim.zeropad + mod( d2,2); 

    subband =sim.subband1;
    out = zeros( 1 ,  d2 * subband+ zeropad) ;
    
    if ( sim.subband == 2 )
         
        out1 =circshift( [in1(1,:) , in2(1,:), zeros(1,zeropad/sim.subband) ],[0, round(delay(1)/2)]) ;
        out2 =circshift( [in1(2,:) , in2(2,:), zeros(1,zeropad/sim.subband) ],[0, round(delay(2)/2)]) ;
        temp = TXOFDE2(out1, out2, fiber, params, sim,  2 );

    end
    if ( sim.subband == 4 )
        out1 =circshift( [in1(1,:) , in2(1,:), zeros(1,zeropad/1) ],[0, round(delay(1)/subband)]) ;
        out2 =circshift( [in1(2,:) , in2(2,:), zeros(1,zeropad/1) ],[0, round(delay(2)/subband)]) ;
        out3 =circshift( [in1(3,:) , in2(3,:), zeros(1,zeropad/1) ],[0, round(delay(3)/subband)]) ;
        out4 =circshift( [in1(4,:) , in2(4,:), zeros(1,zeropad/1) ],[0, round(delay(4)/subband)]) ;
        temp = TXOFDE4(out1, out2, out3, out4, fiber, params, sim,  2 );
    end
    
    if ( sim.subband == 8 )
        out1 =circshift( [in1(1,:) , in2(1,:), zeros(1,zeropad/1) ],[0, round(delay(1)/subband)]) ;
        out2 =circshift( [in1(2,:) , in2(2,:), zeros(1,zeropad/1) ],[0, round(delay(2)/subband)]) ;
        out3 =circshift( [in1(3,:) , in2(3,:), zeros(1,zeropad/1) ],[0, round(delay(3)/subband)]) ;
        out4 =circshift( [in1(4,:) , in2(4,:), zeros(1,zeropad/1) ],[0, round(delay(4)/subband)]) ;
        out5 =circshift( [in1(5,:) , in2(5,:), zeros(1,zeropad/1) ],[0, round(delay(5)/subband)]) ;
        out6 =circshift( [in1(6,:) , in2(6,:), zeros(1,zeropad/1) ],[0, round(delay(6)/subband)]) ;
        out7 =circshift( [in1(7,:) , in2(7,:), zeros(1,zeropad/1) ],[0, round(delay(7)/subband)]) ;
        out8 =circshift( [in1(8,:) , in2(8,:), zeros(1,zeropad/1) ],[0, round(delay(8)/subband)]) ;
        temp = TXOFDE8(out1, out2, out3, out4, out5, out6, out7, out8, fiber, params, sim,  2 );
    end
    out = temp(:, 1:d2 * subband+ zeropad);
    
end 



function [ out, phase ] = TXOFDE2(in1, in2, fiber, params, sim, Overlap, Freqshift )
    [d1, d2] = size( in1);
         
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ;       
    MaxFreq = 1/params.SampleTime;
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/params.NOFDE);
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 

    freq_shift = []; 
    for ii=1:sim.subband
        freq_shift = [freq_shift ...
            coef * round(sim.delay(ii)/2)*2 * ones(1, params.NOFDE/sim.subband) * 2 ]; 
    end
        
    tmp = - ( w .* w ) + ( w .* freq_shift * 2* pi * MaxFreq/params.NOFDE );
    DHat = 1/2*fiber.Beta2 *( (tmp)  ) * sim.FiberLength  ;
    
    FFTPoint = params.NOFDE/Overlap/2;

    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in1 = [zeros( d1, params.NOFDE/2), in1, zeros( d1, pad)];      
    in2 = [zeros( d1, params.NOFDE/2), in2, zeros( d1, pad)];      
        
    out1 = overlap_fft2( in1, in2, ceil( (d2+ params.NOFDE/2)/FFTPoint), FFTPoint, 1j*DHat, Overlap,  sim.subband); 

    cutting = (Overlap-1) * FFTPoint;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE-cutting+(d2)*2);
    phase =   DHat;
end


function out = overlap_fft2( in1_time, in2_time, fftnum, fftsize,  DHat, Overlap,  IFFTov)
     dispersion_op = ones( size(in1_time,1),1) * exp(DHat);
     IFFTSize = fftsize*IFFTov;
    for fftstep=1:fftnum
        AFreq1 = fft( in1_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq2 = fft( in2_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
         
        BFreq = [ AFreq1, AFreq2];
        CFreq = BFreq; 
        BTime = ifft (dispersion_op  .* CFreq, [], 2 );
%         BTime = ifft( CFreq , [], 2 );
        cutting = (Overlap-1) * IFFTSize/2;
        ATime( :, (fftstep-1)*IFFTSize+1:(fftstep)*IFFTSize) = BTime(:,cutting+1:cutting+IFFTSize) ;
    end
    out = ATime;
end




function [ out, phase ] = TXOFDE4(in1, in2, in3, in4, fiber, params, sim, Overlap, Freqshift )
    [d1, d2] = size( in1);
         
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ;       
    MaxFreq = 1/params.SampleTime;
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/params.NOFDE);
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 

    freq_shift = [];   
    for ii=1:sim.subband
        freq_shift = [freq_shift ...
            coef * round(sim.delay(ii)/2)*2 * ones(1, params.NOFDE/sim.subband) * 2 ]; 
    end
    
    if ( sim.subband == 4)
        m =params.NOFDE/params.NFFT; 
        o=sim.subband1;
        freq_shift(1,:) =  [ ones(1,64*m) * round(sim.delay(1)/o)*o, ones(1,64*m) * round(sim.delay(3)/o)*o];
        freq_shift(2,:) =  [ ones(1,64*m) * round(sim.delay(2)/o)*o, ones(1,64*m) * round(sim.delay(4)/o)*o];
        
        freq_shift = coef * freq_shift * 2;
    end

    
    tmp(1,:) = - ( w .* w ) + ( w .* freq_shift(1,:) * 2* pi * MaxFreq/params.NOFDE );
    tmp(2,:) = - ( w .* w ) + ( w .* freq_shift(2,:) * 2* pi * MaxFreq/params.NOFDE ); 
    DHat = 1/2*fiber.Beta2 *( (tmp)  ) * sim.FiberLength  ;
    
    subband =sim.subband1;
    FFTPoint = params.NOFDE/Overlap/subband;

    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in1 = [zeros( d1, params.NOFDE/subband), in1, zeros( d1, pad)];      
    in2 = [zeros( d1, params.NOFDE/subband), in2, zeros( d1, pad)];      
    in3 = [zeros( d1, params.NOFDE/subband), in3, zeros( d1, pad)];      
    in4 = [zeros( d1, params.NOFDE/subband), in4, zeros( d1, pad)];      
        
    out1 = overlap_fft4( in1, in2, in3, in4 , ceil( (d2+ params.NOFDE/subband)/FFTPoint), FFTPoint, 1j*DHat, Overlap,  subband); 

    cutting = (Overlap-1) * params.NOFDE/4;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE-cutting+(d2)*subband);
    phase =   DHat;
end


function out = overlap_fft4( in1_time, in2_time, in3_time, in4_time,fftnum, fftsize,  DHat, Overlap,  IFFTov)
     dispersion_op = ones( size(in1_time,1),1) * exp(DHat);
     IFFTSize = fftsize*IFFTov;
    for fftstep=1:fftnum
        AFreq1 = fft( in1_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq2 = fft( in2_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
                        
        AFreq3 = fft( in3_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq4 = fft( in4_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
                            
        BFreq(1,:) = [AFreq1, AFreq3];
        BFreq(2,:) = [AFreq2, AFreq4];
        CFreq = BFreq; 
        CFreq = dispersion_op  .* BFreq; 
        BTime = ifft( CFreq(1,:)+CFreq(2,:) , [], 2 ); 
        cutting = (Overlap-1) * IFFTSize/2;
        
        ATime( :, (fftstep-1)*IFFTSize+1:(fftstep)*IFFTSize) = BTime(:,cutting+1:cutting+IFFTSize) ;
    end
    out = ATime;
end



function [ out, phase ] = TXOFDE8(in1, in2, in3, in4, in5, in6, in7, in8, fiber, params, sim, Overlap, Freqshift )
    [d1, d2] = size( in1);
         
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ;       
    MaxFreq = 1/params.SampleTime;
    coef =params.SampleTime /( 2* pi*fiber.Beta2 * sim.FiberLength )/(MaxFreq/params.NOFDE);
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 

    freq_shift = []; 
    phase_shift =[];
     middle_sc = round ( params.NFFT/2 / (sim.subband /2));
    delay_idx  = [ 0:sim.subband/2-1 -sim.subband/2:-1] * middle_sc  + middle_sc/2; 
    m =params.NOFDE/params.NFFT;
    o=sim.subband1;
    freq_shift(1,:) =  [ ones(1,64*m) * round(sim.delay(1)/o)*o, ones(1,64*m) * round(sim.delay(5)/o)*o];
    freq_shift(2,:) =  [ ones(1,64*m) * round(sim.delay(2)/o)*o, ones(1,64*m) * round(sim.delay(6)/o)*o];
    freq_shift(3,:) =  [ ones(1,64*m) * round(sim.delay(3)/o)*o, ones(1,64*m) * round(sim.delay(7)/o)*o];
    freq_shift(4,:) =  [ ones(1,64*m) * round(sim.delay(4)/o)*o, ones(1,64*m) * round(sim.delay(8)/o)*o];

    freq_shift = coef * freq_shift * 2;

    
    for ii=1:4
        tmp(ii,:) = - ( w .* w ) + ( w .* freq_shift(ii,:) * 2* pi * MaxFreq/params.NOFDE );
    end 
    DHat = 1/2*fiber.Beta2 *( (tmp)  ) * sim.FiberLength  ;
    
    subband =sim.subband1;
    FFTPoint = params.NOFDE/Overlap/subband;

    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in1 = [zeros( d1, params.NOFDE/subband), in1, zeros( d1, pad)];      
    in2 = [zeros( d1, params.NOFDE/subband), in2, zeros( d1, pad)];      
    in3 = [zeros( d1, params.NOFDE/subband), in3, zeros( d1, pad)];      
    in4 = [zeros( d1, params.NOFDE/subband), in4, zeros( d1, pad)];      
    in5 = [zeros( d1, params.NOFDE/subband), in5, zeros( d1, pad)];      
    in6 = [zeros( d1, params.NOFDE/subband), in6, zeros( d1, pad)];      
    in7 = [zeros( d1, params.NOFDE/subband), in7, zeros( d1, pad)];      
    in8 = [zeros( d1, params.NOFDE/subband), in8, zeros( d1, pad)];  
        
    out1 = overlap_fft8( in1, in2, in3, in4 ,in5, in6, in7, in8, ceil( (d2+ params.NOFDE/subband)/FFTPoint), FFTPoint, 1j*DHat, Overlap,  subband); 

    cutting = (Overlap-1) * params.NOFDE/4;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE-cutting+(d2)*subband);
    phase =   DHat;
end


function out = overlap_fft8( in1_time, in2_time, in3_time, in4_time, ...
    in5_time, in6_time, in7_time, in8_time, ...
    fftnum, fftsize,  DHat, Overlap,  IFFTov)
     dispersion_op = ones( size(in1_time,1),1) * exp(DHat);
     IFFTSize = fftsize*IFFTov;
    for fftstep=1:fftnum
        AFreq1 = fft( in1_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq2 = fft( in2_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
                        
        AFreq3 = fft( in3_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq4 = fft( in4_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
       AFreq5 = fft( in5_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq6 = fft( in6_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
                        
        AFreq7 = fft( in7_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        AFreq8 = fft( in8_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
                            
        BFreq(1,:) = [AFreq1, AFreq5];
        BFreq(2,:) = [AFreq2, AFreq6];
        BFreq(3,:) = [AFreq3, AFreq7];
        BFreq(4,:) = [AFreq4, AFreq8];
        CFreq = BFreq; 
        CFreq = dispersion_op  .* BFreq; 
        BTime = ifft( CFreq(1,:)+CFreq(2,:) +CFreq(3,:)+CFreq(4,:), [], 2 ); 
        cutting = (Overlap-1) * IFFTSize/2;
        
        ATime( :, (fftstep-1)*IFFTSize+1:(fftstep)*IFFTSize) = BTime(:,cutting+1:cutting+IFFTSize) ;
    end
    out = ATime;
end