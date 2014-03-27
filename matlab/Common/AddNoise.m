function noise = AddNoise( AIN, noise_power_dBm)

    %noise_power_dBm :  noise power of each channel (i,q)
    mV=1e-3;
    noise_power = 10^(noise_power_dBm/10)*mV ;
    noise=sqrt(noise_power)*(randn(size(AIN)) + 1j*randn(size(AIN)));
    
end