overSampling_Factor=2;
Input_bit = [zeros(1,144), exp(((1:144)-8)*8j*pi/128), exp(((1:144)-8)*8j*pi/128) ]; %Bits to be transmitted
Input_bit =[1];
Input_bit_os=upsample(Input_bit,overSampling_Factor); %oversampling
alpha=0.75; % roll-off factor of Root Raised Cosine Filter
pt = SRRC(overSampling_Factor,alpha,8); % impulse response of SRRC filter

% [output_of_srrc_filter] = digfilt( 1, Input_bit, pt );
output_of_srrc_filter = conv(Input_bit_os,pt);
figure; hold on;
stem(real(output_of_srrc_filter));
OFD(output_of_srrc_filter,1e9)
title('Response of SRRC Filter at Tx side')
xlabel('Samples')
ylabel('Amplitude')
OFD(output_of_srrc_filter,1/params.SampleTime)
