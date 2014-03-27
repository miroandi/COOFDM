%% Find Carrier frequency offset and compensate CFO.

function [ out_SCFOcomp,cfo_phase, cfo_phase_16,cfo_phase_17 , iqamp] = ...
            NRxSFCO( channel_in, params, sim)   

    %% Find Carrier frequency offset  

    [d1, d2] = size (channel_in);
    RXSymbolidx = (params.MIMO_emul *params.lenSTF) +1:params.RxOVERSAMPLE:size(channel_in,2 ); 
    for istream=1: params.RXstream
        [ cfo_phase1(istream), cfo_phase_16, cfo_phase_17]= ...
            NRxSCFOcor( channel_in(istream,RXSymbolidx), params, sim  )  ;
    end
    cfo_phase = mean(cfo_phase1);
    
    if ( params.MIMO_emul == 1 && sim.enSCFOcomp == 0  )
        if ( sim.FiberLength ~= 0 )
            cfo_phase=  ( 100)/( 10e9/2/pi/1e6);% 0.0628;
        else
            cfo_phase=  0;
        end
    end
    cfo_phase = cfo_phase /params.RxOVERSAMPLE;    
    
    %% CFO compensation 
%     out_SCFOcomp = channel_in(:,1:d2) .* ( ones(d1,1) * Change_fixed_bit_lim( exp( -1j * cfo_phase * ((1:d2) -432 )), sim.ADCbit , 1));
    out_SCFOcomp =   ( exp( -1j * cfo_phase * ((1:d2)  )))  ;
    out_SCFOcomp = channel_in(:,1:d2) .* ( ones(d1,1) * out_SCFOcomp);
%     out_SCFOcomp = Change_fixed_bit(out_SCFOcomp, sim.MulOutbit );
    iqamp=0;

end 