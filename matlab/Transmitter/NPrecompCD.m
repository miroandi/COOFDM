function ofdmout       = NPrecompCD(preambleout, ofdmoutd, sim, params, fiber)
    if ( sim.precomp_en == 2 )
        ofdmout = NPrecompCD_ver2(preambleout , ofdmoutd, sim, params, fiber);   
    end  
    if ( sim.precomp_en == 3 )
        ofdmout = NPrecompCD_ver3(preambleout , ofdmoutd, sim, params, fiber); 
    end
    if ( sim.precomp_en ==  4)
        ofdmout = NPrecompCD_ver4(preambleout , ofdmoutd, sim, params, fiber); 
    end
    if ( sim.precomp_en == 1 || sim.precomp_en == 0 )
        ofdmout = NPrecompCD_ver1 (preambleout , ofdmoutd, sim, params); 
    end

end 
