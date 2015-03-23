function [ ofdmout ]=  TxMain( dataf,preambleout, sim, params, txedfa, edfa, laser, fiber,MZmod )
%=================  Transmitter =================
        mapperout     = NMapper( dataf,  params );
        pilotout      = NPilot( mapperout, params );
        if ( params.Nstream == 1)
            ofdmoutd      = IFFTnAddCP_PreComp( pilotout, params, sim ); 
            ofdmout1       = NPrecompCD(preambleout, ofdmoutd, sim, params, fiber);
        else
            ofdmoutd      = IFFTnAddCP_PreComp( pilotout(1,:), params, sim );              
            ofdmout1(1,:) = NPrecompCD(preambleout(1:size(preambleout,1)/2,:) , ofdmoutd, sim, params, fiber);              
            ofdmoutd      = IFFTnAddCP_PreComp( pilotout(2,:), params, sim );              
            ofdmout1(2,:) = NPrecompCD(preambleout((size(preambleout,1)/2+1):size(preambleout,1),:) , ofdmoutd, sim, params, fiber);                      
        end        
    
        ofdmout = ofdmout1; 
 
        level =1 ; span = sim.span ;
        if ( sim.multi_level == 1 )   level = sim.span; span = 1 ;   end
        for ii=1:level
            [ofdmout, phase]= OFDE((sim.en_OFDE == 2 || sim.en_OFDE == 3),ofdmout, fiber, params, sim,span * sim.ofde  , 2 ); 
            ofdmout = SPMPreComp( ofdmout, fiber, edfa, sim, laser,span, txedfa, MZmod);
        end
        ofdmout = NLowPassFilter( ofdmout, sim, sim.txLPF_en );
        ofdmout = sim.dacout * ofdmout;
        ofdmout = Change_fixed_bit_lim( ofdmout, sim.DACbit, sim.DACLim );

        ofdmout =  NPreemphasis( sim.txPreemp_en, ofdmout, sim.txpreemp ) ;
        [ofdmout] = digfilt( sim.SRRC_en, ofdmout, sim.srrc_ov, sim.srrc_coef );
end