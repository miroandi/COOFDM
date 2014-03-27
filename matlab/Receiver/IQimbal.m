function [iq_out, iqamp] = IQimbal(enIQbal, channel_in)    

    iq_out =channel_in;
    iqamp=zeros(1,size(channel_in,1));
    if (  enIQbal ~= 0 )
    if ( size(channel_in,1) == 1 )    
        iq=channel_in(1,   :);
        iqamp =  sqrt( mean(real(iq).^2)/ mean(imag(iq).^2))
        power_mean = mean(abs(iq).^2);
        
        iq_out = complex( real(channel_in), imag(channel_in) * iqamp); 
    else
    
        iq=channel_in(1, :);
        iqamp(1) =  sqrt( mean(real(iq).^2)/ mean(imag(iq).^2)) ;
        iq1=channel_in(2,  :);
        iqamp(2) =  sqrt( mean(real(iq1).^2)/ mean(imag(iq1).^2)) ;
        polamp=1;%sqrt( mean(imag(iq).^2)/ mean(imag(iq1).^2));
        iq_out(1,:) = complex( real(channel_in(1,:)), imag(channel_in(1,:)) * iqamp(1) );
        iq_out(2,:) = complex( real(channel_in(2,:)), imag(channel_in(2,:)) * iqamp(2) );
    end
    end
end