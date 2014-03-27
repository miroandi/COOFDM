function [ out, phase ] = OFDE(en_OFDE, in, fiber, params, sim, span, Overlap )
    if ( en_OFDE == 0 )
        out = in ;
        phase = 0;
        return
    end
    
    [d1, d2] = size( in);
    
    %% Phase 
    w = [0:(params.NOFDE)/2-1 -(params.NOFDE)/2:-1]   ; 
    w0 = w * 0;
    w= 2*pi * 1/params.SampleTime/params.NOFDE * w ; 
    FFTPoint = params.NOFDE/Overlap;
    DHat = 1/2*fiber.Beta2 *( - w .* w + w0 .^2 ) * sim.FiberLength * 1 /sim.span * span ;
        
    
    %% Zero padding to process overlapped FDE(OFDE)
    pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
    in = [zeros( d1, params.NOFDE), in, zeros( d1, pad)];      
        
    out1 = overlap_fft( in, ceil( (d2+ params.NOFDE)/FFTPoint), FFTPoint, 1j*DHat, Overlap); 
    cutting = (Overlap-1) * FFTPoint/2;
    out = out1( :, params.NOFDE+1-cutting:params.NOFDE+d2-cutting);
    phase =   DHat;
end

     
function out = overlap_fft( in_time, fftnum, fftsize,  DHat, Overlap)
     dispersion_op = ones( size(in_time,1),1) * exp(DHat);
%      H = dlmread( 'CH.txt')
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
%         BTime = ifft ( angle(conj(H))  .* AFreq, [], 2 );
         BTime = ifft (dispersion_op  .* AFreq, [], 2 );
        cutting = (Overlap-1) * fftsize/2;
        ATime( :, (fftstep-1)*fftsize+1:(fftstep)*fftsize) = BTime(:,cutting+1:cutting+fftsize) ;
    end
    out = ATime;
end