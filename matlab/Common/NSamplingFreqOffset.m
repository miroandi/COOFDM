function out = NSamplingFreqOffset( freqoff, timeoff, in )

if ( freqoff == 0 && timeoff == 0 )
    out = in;
else
    filterlength = 32 ;  % Number of Tap ;; Dont change.
    filterlength_2 = filterlength/2 ;

    timing_delay = timeoff +freqoff*( 0:1:length(in)-1);
    tim_filter = zeros( length(in), filterlength);
    for iFilterNum=1:filterlength
            filter_delay =  (timing_delay + iFilterNum - filterlength/2 ) ;
            tim_filter(:, iFilterNum) = sinc(filter_delay) ;
    end

    [d1, d2] =size(in);
    in=[zeros(d1,filterlength_2), in,zeros(d1,filterlength_2)];
    out =zeros(d1,d2);
    for np=1:d1
        for iSample=1:d2 
                out(np,iSample) = sum(tim_filter(iSample, :) .* in(np, iSample+1 :iSample+filterlength));
        end
    end 
%     for np=1:d1
%         for iSample=1:d2 
%                 out(np,1:d2) = sum(tim_filter(1:d2, :) .* in(np, iSample+1 :iSample+filterlength));
%         end
%     end 

end
end
