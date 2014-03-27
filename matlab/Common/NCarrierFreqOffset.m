function out = NCarrierFreqOffset( in, freqoff )
    if ( freqoff ~= 0 )
        phaseoff = 2*pi*freqoff*(1:length(in));
        out  = in .* (ones(size(in,1), 1) *exp( phaseoff * 1i));
    else
        out  = in;
    end
end 