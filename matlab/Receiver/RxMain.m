function [demapperout, fftout, H_modified, cfo_phase, commonphase, snr, fsync_point] = RxMain( noisyreceivein, params, sim ,fiber )
%===================== Receiver ===================================        
    [noisyreceivein] = digfilt( sim.SRRC_en, noisyreceivein,sim.srrc_ov, sim.srrc_coef );
    agcout = NRxAGC (noisyreceivein, params, sim);
    adcout = Change_fixed_bit_lim(agcout, sim.ADCbit, 2^(sim.ADCbit-1)-1);
    
    %% CFO 
   [ adcout,cfo_phase,cfo_phase_8,cfo_phase_17,iqamp ] = NRxSFCO( adcout, params, sim) ;
   
   %% OFDE, SPM
    prev_in =[adcout(:, (size(adcout,2)-(params.NOFDE)+1):size(adcout,2)), adcout];
    level =1 ; span = sim.span ;
    if ( sim.multi_level == 1 )   level = sim.span; span = 1 ;   end
%     (sqrt(1e-3)/sqrt(mean(sum(abs(prev_in).^2,1))) )  ^2
   for ii=1:level                  
        [prev_in, phase] = OFDE((sim.en_OFDE == 1 || sim.en_OFDE == 3), ...
                              prev_in, fiber, params, sim,span * sim.ofde, 2 );          
        prev_in       = SPMPostComp( prev_in,  params.MIMO_emul, ...
                         sim.fiber, sim.edfa, sim, span, sim.rxedfa, sim.PD);  
%             adctmp(ii, :) = adcout(1,:); 
   end   
    
    adcout = prev_in(:,params.NOFDE+1:size(prev_in,2));
    %% Only for simulation, Frame synchronization.
    if ( sim.en_find_cs == 1)
        prev_in = adcout(:, size(agcout,2)-300:size(agcout,2));
        adcout=[prev_in, adcout];
        cs_idx = NRxFindCS_MIMO_energy( adcout, params,sim, 0);
        adcout = [adcout(:, cs_idx:size(adcout, 2)), zeros(size(adcout,1),20) ];
    end
     
     %% CFO 
     scfo_comp = adcout; iqamp=0; 
%     
%     [ scfo_comp,cfo_phase,cfo_phase_8,cfo_phase_17,iqamp ] = NRxSFCO( adcout, params, sim) ;
    %% Symbol synchronization
    [ sync_out,fsync_point ]                         = NRxSync( scfo_comp, params, sim)   ;
    %% Frequency domain
    [H, channelout, LTF_t, LTF2_t]                   = NRxChannelEst( sync_out, params, sim,iqamp); 
    H_modified                                       = ISFA( H, sim, params); 
 
    [fftout, commonphase, timingoffset, snr]         = FFTnComp( channelout, H_modified, params, sim, LTF_t, LTF2_t);
    demapperout                                      = NRxDemapper( params.en_bitalloc , fftout, params );
end

     
