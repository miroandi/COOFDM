%% Find symbol synchronization

function [ channel_out,fsync_point ] = NRxSync( channel_in, params, sim)   
 
    %% ideal synchronization     
    if (   sim.precomp_en == 1)        
		delay_diff =  sim.delay(params.NFFT) - sim.delay(1);
        STFidx =( sim.delay(1)+(params.NSTF+params.MIMO_emul *2 )*params.lenSTF + round( delay_diff/2-2 ) + 2 )* params.RxOVERSAMPLE; 
    else        
        STFidx =( (params.NSTF+params.MIMO_emul *2 )*params.lenSTF   )* params.RxOVERSAMPLE; 
    end
     
    %% Real synchronization ( Find the Maximum valued synchronization)
    
    fsync_point = 0 ;
    if ( sim.en_find_sync == 1 )
        SyncStart = STFidx - (params.lenSTF*params.NSTF *params.RxOVERSAMPLE)+1;
        SyncEnd   = STFidx + params.SampleperSymbol*(params.NLTF +2)*params.RxOVERSAMPLE;
        in_sync   = channel_in(:,SyncStart: params.RxOVERSAMPLE:SyncEnd);
        [idx1 , MaxVal1 ] = NRxFindSync( in_sync, sim, params, sim.en_fsync_plot );
        idx = idx1(MaxVal1==max(MaxVal1));

        if ( abs(idx) > 3 )
        %             disp( ['sync fail difference: ' num2str(idx)]);
        end
        STFidx = STFidx + params.RxOVERSAMPLE * idx ;
        fsync_point = idx ;
    end
    
    %% LTF, Data symbols 
    channel_out = channel_in(:, STFidx+1:size(channel_in,2));
end
 