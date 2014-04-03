function AOUT = NPreemphasis( preemphasis_filter_en, AIN, pre )    

    AOUT =AIN;
    if ( preemphasis_filter_en == 0 )
      return;    
    else
        for ii=1:size(AIN,1)
            AOUT(ii,:) = filter(pre.b, pre.a,AIN(ii,:));
        end
    end
