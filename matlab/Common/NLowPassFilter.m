
function out= NLowPassFilter( in, sim, en)
    [d1, d2] = size(in);
    out= zeros(d1, d2);    
    if ( en == 0 )
        out = in ;
    else
        for jj=1:d1
            inr = interp1(1:d2+1, [ real(in(jj,1:d2)) 0],1:1/2:d2+1/2);
            ini = interp1(1:d2+1, [ imag(in(jj,1:d2)) 0],1:1/2:d2+1/2);
            filteroutr = filtfilt( sim.txfilterb, sim.txfiltera, inr );
            filterouti = filtfilt( sim.txfilterb, sim.txfiltera, ini );
              out(jj,:) = complex( filteroutr(2:2:2*d2), filterouti(2:2:2*d2));   
%             filteroutr = filtfilt( sim.txfilterb, sim.txfiltera, real(in(jj,1:d2)) );
%             filterouti = filtfilt( sim.txfilterb, sim.txfiltera, imag(in(jj,1:d2)) );
%             out(jj,:) = complex( filteroutr, filterouti);           
        end   
    end
end