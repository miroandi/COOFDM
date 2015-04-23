function print_parameters(logfile, sim,params )
validsymbolrate = params.NSymbol/(params.NSymbol+params.NSTF+params.NLTF* params.RXstream+2);
normdatarate = params.Ncbps  *params.RXstream/(params.SampleTime * params.SampleperSymbol );
datarate =normdatarate*validsymbolrate;
km =1e3; GHz=1e9;
disp2(logfile, ' ===============================');
disp2(logfile, ' ');
% disp2( logfile,['Fixed ', num2str( sim.fixed_sim)]);
%     disp2( logfile,['ADC, Mul, Tan in/out', ...
%         num2str(sim.ADCbit),', ', ...
%         num2str(sim.MulOutbit),', ', ...
%         num2str(sim.ATANINbit), ...
%         ', ', num2str(sim.ATANbit)]);

%     disp2( logfile,['No Noise ', num2str(sim.nonoise)]);
%     disp2( logfile,['SNR1 ', num2str(sim.SNR(1)), ' ']);
%     disp2( logfile,['backtoback ', num2str(sim.backtoback)]);
%     disp2( logfile,['FiberLength(km) ', num2str(sim.FiberLength/km)]);
%     disp2( logfile,['Linewidth(kHz) ', num2str(laser.linewidth/kHz)]);
%     disp2( logfile,['SFO(ppm) ', num2str(sim.txfreqoff/ppm)]);
%     disp2( logfile,['CFO(MHz) ', num2str(laser.freqoff/MHz)]);
%     disp2( logfile,['CFO(norm) ', num2str(laser.freqoff*2*pi*params.SampleTime)]);
    disp2( logfile,['Number of symbols per packet ', num2str(params.NSymbol)]);
    disp2( logfile,['Number of simulation per each point ', num2str(sim.MAXSIM)]);
    disp2( logfile,['Sampling frequency ', num2str(1/params.SampleTime /GHz),' GHz']); 
    % disp2( logfile,['TX Laser power ', num2str(10*log10( launch_power/mW)   ),' dBm']);     
    % disp2( logfile,['TX Gain ', num2str(10*log10(laser.launch_power/mW)   ),' dBm']);       
    disp2( logfile,['Modulation ', num2str( 2^params.Nbpsc ), ' QAM ']);
    disp2( logfile,['Data rate ', num2str( datarate / 10^9  ), 'Gbps ']);              
    disp2( logfile,['Data rate ', num2str( normdatarate / 10^9  ), 'Gbps ']);
    disp2( logfile,['FFT size ', num2str( params.NFFT ), ' ', 'CP cnt', num2str(params.NFFT * params.CPratio)]);
    disp2( logfile,['syncpoint ', num2str(sim.syncpoint ), ' ']);
%     disp2( logfile,['Precomp enable ', num2str(  sim.precomp_en ), '. subband ', num2str(sim.subband)]);
    disp2( logfile,['CPE enable ', num2str(  sim.enCPEcomp )]);
    disp2( logfile,['CFO type ', num2str(  sim.cfotype)] ); 
    disp2( logfile,['Symbol sync search: ', num2str(  sim.en_find_sync)] );
    disp2( logfile,['I/Q imbalnace check: ', num2str(  sim.enIQbal )] );
    disp2( logfile,['S CFO compensation: ', num2str( sim.enSCFOcomp )] );
    disp2( logfile,[' CFO compensation: ', num2str( sim.enCFOcomp )] );
    disp2( logfile,['MIMO emul: ', num2str( params.MIMO_emul )] );
    disp2( logfile,['OFDE : ', num2str( sim.en_OFDE ),' OFDE size: ', num2str( params.NOFDE ),' ofde coef : ', num2str( sim.ofde )] );
    disp2( logfile,['SPM : ', num2str( sim.nlpostcompen )] );
      
    if ( sim.fixed_sim == 1 ) 
        disp2( logfile,['ADC  bit    : ', num2str( sim.ADCbit )] );
        disp2( logfile,['DAC  bit    : ', num2str( sim.DACbit )] );
        disp2( logfile,['CS in bit   : ', num2str( sim.CSInbit )] );
        disp2( logfile,['CS Mul bit  : ', num2str( sim.CSMulOutbit )] );
        disp2( logfile,['CS Sum out bit: ', num2str( sim.CSSumOutbit )] );
        disp2( logfile,['CFO in (Frac.) bit : ', num2str( sim.CFOinbit  )] );
        disp2( logfile,['CFO mul (Frac.) bit : ', num2str( sim.CFOMulOutbit )] );
        disp2( logfile,['CFO sum (Frac.) bit : ', num2str( sim.CFOSumOutbit )] );
        disp2( logfile,['CFO in (Int.) bit : ', num2str( sim.CFO1inbit )] );
        disp2( logfile,['CFO mul (Int.) bit : ', num2str( sim.CFO1MulOutbit )] );
        disp2( logfile,['CFO sum (Int.) bit : ', num2str( sim.CFO1SumOutbit )] );
        disp2( logfile,['CFO angle(out) bit : ', num2str( sim.CFObit )] );
        disp2( logfile,['FS in bit : ', num2str( sim.FSInbit )] );
        disp2( logfile,['fS Mul bit : ', num2str( sim.FSMulOutbit )] );
        disp2( logfile,['FS Sum out bit: ', num2str( sim.FSSumOutbit )] );
        disp2( logfile,['FS approx.: ', num2str( sim.FSEst )] );        
    end
    disp2(logfile,datestr(now,'HH:MM /mm/dd/yy'))
    disp2(logfile, ' ===============================');
end
