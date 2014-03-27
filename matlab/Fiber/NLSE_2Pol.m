function aout = NLSE_2Pol( ain, fiber) % DeltaT,DeltaH, Beta2, Alpha, Gamma, FiberLength)
%function [ATime, AFreq]  = NLSE( ain,  DeltaT,DeltaH, Beta2, Alpha, Gamma, FiberLength)
% This function is for Nonlinear Schrodinger equation simulation.
%
%  NOTE : In this simulation all variables are frequency independent for
%  simplicity.
%  Input variables
%  ain     : Input 
%  DeltaT  : Sampling rate of ain. ( second )
%  DeltaH : Segment of fiber length ( meter )
%  Beta2  : 2nd order disp. (s^2/m)
%  Alpha   : Fiber loss ( dB/m?)
%  Gamma   : Nonlinear coefficient  
%  FiberLength : Fiber length

    j=sqrt(-1);
    [d1, d2]= size(ain);
    if ( fiber.FFTSize == 0 )         
        Overlap = 1;
        FFTPoint = d2 ;
        NumTimesample = d2;        
        ATime = ain; 
    else
        Overlap = fiber.Overlap;
        FFTPoint = fiber.FFTSize ;
        NumTimesample = fiber.FFTSize*Overlap;
        pad = FFTPoint* (ceil(d2/FFTPoint))+ FFTPoint*(Overlap-1)-d2;
        ATime = [ain, zeros( d1, pad)];      
        
    end
    MaxStep = ceil (fiber.FiberLength/fiber.DeltaH)+1 ;
    
    if ( mod ( NumTimesample, 2) == 1 ) 
        w = [0:(NumTimesample )/2 -(NumTimesample -1)/2:-1];
       
    else
        w = [0:(NumTimesample)/2-1 -(NumTimesample)/2:-1];
    end
	if ( fiber.centered == 0 )
        w = [0:NumTimesample-1];
	end
    w= 2*pi * 1/NumTimesample/fiber.DeltaT * w ;
    DHat = -1j/2*fiber.Beta2 *( - w .* w  ) *fiber.DeltaH - fiber.Alpha/2*fiber.DeltaH ;
    dispersion = ones(d1,1) * exp(DHat);

   
    NLATime = zeros(d1, length(ATime)); 
    
    LHat = 1j * fiber.Gamma * fiber.DeltaH;
    ATime_prev = ATime;
    
    
    % Main loop to calculate NLSE 
      for h = 2:MaxStep
        NLATime=   exp( nonlinear_op( LHat, ATime )) .* ATime ;
        ATime = fiber_fft( NLATime, ceil(d2/FFTPoint), FFTPoint, DHat, Overlap);         
      end


    aout=ATime(:,1:d2);
    
%     PMD = fiber.DGD * fiber.FiberLength/2;
    PMD = fiber.PMD /2;
    aout(1,:) = fiber_fft( aout(1,:), ceil(d2/FFTPoint), FFTPoint,-1j*w*PMD , Overlap);
    aout(2,:) = fiber_fft( aout(2,:), ceil(d2/FFTPoint), FFTPoint,1j*w*PMD , Overlap);


end   

function out = nonlinear_op( LHat, in )
    op(1,:) =  ( LHat * (abs(in(1,:) .* in(1,:)) + 2/3*abs(in(2,:) .* in(2,:)))) ; 
    op(2,:) =  ( LHat * (abs(in(2,:) .* in(2,:)) + 2/3*abs(in(1,:) .* in(1,:)))) ;   
    out = op ;%.* in; 
end

function out = fiber_fft( in_time, fftnum, fftsize,  DHat, Overlap)
     dispersion_op = ones( size(in_time,1),1) * exp(DHat);
    for fftstep=1:fftnum
        AFreq = fft( in_time(:, (fftstep-1)*fftsize+1: ...
                                (fftstep-1+Overlap)*fftsize),[], 2); 
        BTime = ifft (dispersion_op  .* AFreq, [], 2 );
        ATime( :, (fftstep-1)*fftsize+1:(fftstep)*fftsize) = BTime(:,1:fftsize) ;
    end
    out = ATime;
end