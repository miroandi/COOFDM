% Optical signal to electric signal, receiver

function [esignal, phase_noise] =  opt2elec( osignal_in,lolaser, PD, rxedfa, sim,params)
    [d1,d2]=size(osignal_in);
    
    %% EDFA
    osignal  = EDFA( osignal_in, rxedfa, params ) ;
    osignal = osignal * sqrt(0.0274) * 0.0165/(mean(sum(abs(osignal).^2,1)))   ;
    %% Down-sampling 
    esignal = osignal(:,1:sim.oversample:d2);
    esignal= sim.rx_power_split * esignal;
     
    %% Add phase noise 
    phase_noise =zeros(1,size(esignal,2));

    if ( lolaser.linewidth ~= 0 )
        var =2*pi*lolaser.linewidth* params.SampleTime;
        a = normrnd(0,sqrt(var), [1 size(esignal,2)] );
        b = zeros(1 ,length(a));
        b(1) = a(1);
        for ii=2:length(a)
            b(ii) = b(ii-1) + a(ii);
        end 
        esignal =  esignal .* ( ones(d1, 1) *exp( 1j * b));
        phase_noise =b;
    end
    
    esignal = esignal * PD.responsivity;
    
    %% Add AWGN noise 
    if ( sim.nonoise == 0 && PD.nonoise ==0 )
        opt2ele_noise = AddNoise( esignal, PD.noise_power_dBm);
        esignal =esignal+opt2ele_noise;
    end
    
    %% Coherent receiver
    esignal = esignal * 10^(PD.gain_dB/20) *sqrt(lolaser.launch_power) ;
    
end
