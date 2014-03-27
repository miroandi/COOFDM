function [demapper_out]  = NRxDemapper( en_bitalloc, demapper_in,  params )
    if ( en_bitalloc == 0)
        demapper_out = NRxDemapper_simple( demapper_in,  params );
    else
        demapper_out = NRxDemapper_sc(  demapper_in,  params );
    end
end

