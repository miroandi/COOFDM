function AOUT = TimeJitter( AIN, SampleTime, jitter )    

    AOUT =AIN;
    if ( jitter == 0 )
      return;    
    else
        x = 1:size(AIN,2 );
        jitter_x = x +  (jitter/SampleTime) *(randn(1, size(AIN,2)));
        for ii=1:size(AIN,1)
            AOUT(ii,:) = interp1(x,AIN(ii, :), jitter_x,'spline');  
        end
    end