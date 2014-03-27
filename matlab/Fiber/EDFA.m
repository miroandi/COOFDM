function out = EDFA ( in, edfa, params )
    
    gain =  10^(edfa.gain_dB/20) ;
    
    if ( edfa.nonoise == 1)
        out =in*gain ;
    else
        noise_figure= 10^(edfa.NF_dB /10);
        gain1 =  10^(edfa.gain_dB/10) ;
        noise_density= edfa.hv*( noise_figure*gain1-1)/params.SampleTime/2;
        noise=sqrt( noise_density/2 )*(randn(size(in)) + 1j*randn(size(in)));
        out =in*gain + noise;
    end
end 