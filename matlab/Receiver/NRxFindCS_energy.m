function idx = NRxFindCS_energy( in, params,sim, en_plot)
    t_ltf = ifft(params.LTF)  ;
    t_stf = ifft(params.STF) ;

    search_idx = 64; 
    STF_128 = t_stf(1:search_idx);
    
    frmsyncfinder = in;
    sync_start_idx =1;
    input_length = round( length(frmsyncfinder));
    frmsyncidx = zeros(input_length-1,1);
    sxcr = zeros(input_length-1,1);
    cs = zeros(input_length-1,1);
    idx=1; idx1=1;
    signal_len = 128;
    
    pwr = abs( in ) .^ 2;
    mean_pwr = mean ( mean ( pwr ));
    cs = pwr > mean_pwr /2 ;
%     cs = pwr > mean_pwr *9/10 ;
   posedge = 0 ;
len = 16;
% len=params.NSTF*params.lenSTF/2;
%  
%     
%    
%    k = 1:len;
%    for isample=search_idx+1 :input_length-2*len;
%          
%         P1(isample)= sum( in(isample+k) .* conj(in(isample+len+k)));
%         R1(isample) = sum (abs( in ( isample +k )) .^2 );     
%         Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;
%      
%     end
% 
%     mean_pwr = max(Msym)/4;
%     cs = Msym > 0.5  ;
    
%     if ( sim.cfotype == 5 || sim.cfotype == 8 )
%         input_length = round( length(frmsyncfinder)/2);
%         len =  params.repSTF * params.rep2STF;
%         for isample=search_idx+1 :input_length-2*len;         
%             P1(isample)= sum( in(isample+k) .* conj(in(isample+len+k) *exp(-( 1j )*(sim.tone - 1)*len*pi*2/params.NFFT  )));
%             R1(isample) = sum (abs( in ( isample +k )) .^2 );     
%             Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;     
%         end
%         cs = Msym > 0.5  ;
%     end
    
%     if ( sim.cfotype == 5 || sim.cfotype == 8 )
%         input_length = round( length(frmsyncfinder) );
% %         len =  sim.tone-1;% params.repSTF * params.rep2STF;
%         len =   32;
%         k=1:len;
%         for isample=search_idx+1 :input_length-2*len;         
%             P1(isample)= sum( in(isample+k) .* conj(in(isample+len+k)));
%             R1(isample) = sum (abs( in ( isample +k )) .^2 );     
%             Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;     
%         end
%         cs = Msym > 0.5  ;
%     end
%     signal_len = params.lenSTF *params.NSTF /2;
%     posedge=1;
%     

     
len =64;
k=1:len;
for isample=search_idx+1 :input_length-2*len;                 
        R1(isample)  = sum (abs( in ( isample +k ))  ) ^2;             
end
Msym  =  R1 /  (mean(R1) ) ; 
cs1=Msym > 0.35;
cs=cs1;
posedge=1;
     
    signal_len = sim.zeropad1 /2 ;
    
    
    
%      cs =   Msym < ( max(Msym)/4 + mean(Msym) );
 if ( posedge == 0 )
     val0 = 1;val1 = 0;
     val_off= ( sim.zeropad1  )  ;
     val_off= - params.lenSTF *( params.NSTF + params.MIMO_emul )  + len ;
 else
     val0 = 1;val1 = signal_len-5;
     val_off= ( sim.zeropad1   ) ;

 end
     
if ( sim.cfotype == 7 && ((sim.zeropad3 +sim.zeropad1) == 0 ) ) % No DC interval 
    [P1, R1, Msym, R2] = AutoCorr( in ,search_idx, 16, 4  );             
    cs1=( R1 >  (mean(R1) ) );
    cs2=Msym > (0.6 );
    cs =  cs1 .* cs2;
    signal_len = 24;
    val0 =2;
    val1 = 20;
end    
    
    for isample=search_idx+1+signal_len :input_length-2*len-signal_len;
         
        if ( isample > search_idx+20)
            if ( sum(cs(isample-64:isample-1)) < val0)
                if ( sum(cs(isample:isample+signal_len)) > val1  )
                    idx1=isample ;
                idx = isample +val_off ;
%                 break
%                 return
                end
            end
        end
    end

    

    
    if ( en_plot == 1 )         
        CSFigure( in, cs, Msym, idx1, idx)
    end 
end
