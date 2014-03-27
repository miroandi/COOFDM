  
function [ovosignal, phase_noise] =  elec2opt1( esignal, laser, MZmod, txedfa, sim, params )
    [d1, d2] = size(esignal);
% Electro - Optic conversion 
% 1. Laser linewidth induced phase noise
% 2. Laser freq off.
% 3. Mache-Zender modulator, 
% 4. up-conversion for NLSE simulation 

    osignal  = MZM( real(esignal), MZmod, laser  );
    osignal  = osignal + 1j*MZM( imag(esignal), MZmod, laser  );
    osignal =osignal/sqrt(2);
    osignal  = EDFA( osignal, txedfa, params) ;

    optoofdmout_pz = osignal;
%     noisyoptoofdmout_pz=optoofdmout_pz;
    %% Upsampling 
    if ( sim.oversample == 1 )
        ovosignal=optoofdmout_pz;
    else
        % Upsampling using FFT for NLSE simulation 
%         zeropad = zeros(d1,d2/2*(sim.oversample-1));
%         ovosignal =  sim.oversample * ifft(ifftshift( ...
%           [zeropad ,fftshift(fft(noisyoptoofdmout_pz(:,:), [], 2 ),2), zeropad],2),[],2);
        for istream=1:d1
          ovosignal(istream,:) = interp1(1:d2, optoofdmout_pz(istream,:), ...
             ( 1:(d2*sim.oversample))/sim.oversample,'spline');
        end
    end
    
        % Noise due to thermal noise
    if (sim.nonoise == 1 || sim.en_AWGN == 0 )
        noisyoptoofdmout_pz=ovosignal;
    else        
        noise=AddAWGN(ovosignal, sim.SNR , sim);
        noisyoptoofdmout_pz = ovosignal+noise;
    end
    ovosignal = noisyoptoofdmout_pz;
    if ( laser.linewidth == 0 )
        phase_noise =zeros(1,size(ovosignal,2));
    else
        var = 2*pi*laser.linewidth*params.SampleTime/sim.oversample;
        a =normrnd(0,sqrt(var), [1 size(ovosignal,2)] );
%         a(1+params.NSTF*params.lenSTF:params.NSTF*params.lenSTF+params.NL
%         TF*2*params.SampleperSymbol)=0;
%          a =sqrt(2*pi*laser.linewidth* params.SampleTime/sim.oversample)*randn([1 size(ovosignal,2)] );
        b = zeros(1 ,length(a));        
        b(1) = a(1);
        for ii=2:length(a)
            b(ii) = b(ii-1) + a(ii);
        end 
        ovosignal =  ovosignal .* ( ones(d1, 1) *exp( 1j * b ));
        phase_noise =b;
    end
    
end 