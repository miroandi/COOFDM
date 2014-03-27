function [idx1, idx2 ] = SearchCS( cs ,search_idx, val0, signal_val0,  val1, signal_val1, val_off , break_en )

    input_length = round( size(cs,2)); 
    idx1=input_length -signal_val1-1; idx2=input_length -signal_val1-1;
    for isample=search_idx+signal_val0 +1:input_length -signal_val1-1

        if ( isample > search_idx+20)
            if ( sum(cs(isample-signal_val0:isample-1)) <= val0  )
                if ( sum( cs(isample :isample+signal_val1 )) >= val1  )
                    idx1=isample ;
                    idx2 = isample +val_off  ; 
                    if ( break_en == 1 )
                        break;
                    end
                end
            end
        end
    end
%     if ( break_en == 1 )
%        disp('CS Not found'); 
%     end
end