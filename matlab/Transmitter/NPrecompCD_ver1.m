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
    out = zeros( 1 ,  d2+ zeropad + ( params.rec_window == 0 ) *length(sim.rcfilter) ) ;
    if ( sim.offset_QAM == 1 )
        out =   (  [in1(1,:) , in2(1,:) , zeros(1, zeropad)]);
        out = out +   circshift( ( [in1(2,:) , in2(2,:)  , zeros(1, zeropad)]), [ 0, delay(2)]) ;
    else
        for ii=1:d1
            tmp = [ [in1(ii,:) , in2(ii,:) ], zeros(1, zeropad)]  ;
            tmp = OFDM_window ( ( params.rec_window == 0 ) , tmp, params, sim );
            out =  out + circshift(tmp,[0, delay(ii)]) * exp( -1j* sim.phase (ii) );
        end
    end

end 
        % pulse shaping ( Window)
        
%         ifftout(:, 1:params.WNDsize)
function  out = OFDM_window( en, in, params, sim )
    out = [in] ;
    if ( en ==  0 )
        return;
    end
    out = [in, zeros(1,length(sim.rcfilter))] ;
%     out = [in, zeros(1, params.NFFT*params.CPratio)] ;
    idx =sim.zerohead2:params.SampleperSymbol:size(in,2)-1;
    for ii=1:length(sim.rcfilter)
    out(:,ii+idx)= in(:,ii+idx ) * (1- sim.rcfilter(ii));
    out(:, params.SampleperSymbol +idx + ii)= ...
        out(:, params.SampleperSymbol +idx + ii) + ...
        in(:,  params.NFFT * params.CPratio +idx + ii ) *  (sim.rcfilter(ii));
    end
end
