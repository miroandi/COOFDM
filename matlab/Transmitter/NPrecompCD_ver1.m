function out       = NPrecompCD_ver1(in1, in2, sim, params)

%   Usage
%     ofdmout       = NPrecompCD([preambleout, ofdmoutd], sim.precom_CD); 
%

    delay = sim.delay ; 
    [d1, d2] =size(in1);
    d2 = d2 + size( in2,2);
    zeropad = sim.zeropad + mod( d2,2);
%     zeropad = max(delay)-min(delay)+100;
%     if( mod( zeropad, 2) == 1 ) zeropad = zeropad +1 ; end
    out = zeros( 1 ,  d2+ zeropad) ;
    for ii=1:d1
        tmp = [ [in1(ii,:) , in2(ii,:) ], zeros(1, zeropad)]  ;
%         tmp1=NLowPassFilter( tmp, sim, sim.txLPF_en );
        out =  out + circshift(tmp,[0, delay(ii)]) * exp( -1j* sim.phase (ii) );
    end

end 
