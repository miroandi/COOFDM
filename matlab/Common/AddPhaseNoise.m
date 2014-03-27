function AOUT = AddPhaseNoise( AIN, SampleTime, LineWidth );    

    if ( LineWidth == 0 )
        AOUT =zeros(1,size(AIN,2));
    else
        var = 2*pi* LineWidth *SampleTime;
        a =normrnd(0,sqrt(var), [1 size(AIN,2)] );
        b = zeros(1 ,length(a));        
        b(1) = a(1);
        for ii=2:length(a)
            b(ii) = b(ii-1) + a(ii);
        end 
%         ovosignal =  ovosignal .* ( ones(d1, 1) *exp( 1j * b ));
        AOUT =b;
    end