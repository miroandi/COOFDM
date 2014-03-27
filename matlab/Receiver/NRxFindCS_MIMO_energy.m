function idx = NRxFindCS_MIMO_energy( in1, params,sim, en_plot)


search_idx = 64;  
input_length = round( size(in1,2)); 
cs = zeros(input_length-1,1);
idx1=1;idx2=input_length-100;
len=params.NSTF*params.lenSTF/4;
k = 1:len;

  if ( sim.cfotype == 4 && params.MIMO_emul == 1 )                
        [P1, R1, Msym, R2] = AutoCorr( in1 , 2*params.lenSTF, params.lenSTF, -params.lenSTF  ); 
        cs1=R1 > (mean(R1)*0.6);
        cs  =Msym;
        Msym = cs1 .* Msym ;
        idx1= find( (Msym == max(Msym)));
        idx2=idx1- 2*params.lenSTF;
        len=0;         
  end
  in2 =in1;  
%% Fixed simulation
if (sim.CSInbit ~=0 )
    step =4;
    in2 = Change_fixed_bit2( in1(:,:), sim.CSInbit, sim.ADCbit -sim.CSInbit-1); % SAT 1 bit
    len= 16;
    signal_len = 32;
    k = 1:1:len;
    cs_th = 0.25 ;
    if ( sim.SNR(1) < 7 )
        cs_th = 0.15 ;
    else
        if ( sim.SNR(1) < 10 ) cs_th = 0.20 ; end
    end
    cs_th =0.5; % From off-line experiment
end
%%

for istream=1:size(in1,1)
    in = in2(istream,:);
    %% Conventional CFO based on CRT
    if ( sim.cfotype == 4 && params.MIMO_emul == 0 )                
        [P1, R1, Msym, R2] = AutoCorr( in (:,1:2000),search_idx, params.lenSTF, params.lenSTF  );        
        cs = (Msym == max(Msym));
        idx1= find( (Msym == max(Msym)));
        idx2=idx1;
        len = 0;
    end
    
 
    %% Single frequency CFO based on CRT using 2/1 training symbol
    if ( sim.fixed_sim == 0 && (sim.cfotype == 5 || sim.cfotype == 8 ))
        len=24;%64;
        k = 1:len;
        search_idx=100;
        input_length1 =  input_length; 
        idx1 =input_length1-2*len; idx2=idx1;
        for isample=search_idx+1+2*len :input_length1-2*len;     
            P1(isample)= sum( in(isample+k) .* conj(in(isample+ (sim.tone-1) + k )));
            R1(isample) = sum (abs( in ( isample +k )) .^2 );     
            Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;   
            R2(isample) =   (abs( in ( isample   )) .^2 );   
        end
        break_en=0;
        posedge = 1;
        cs1=( R1 >  (mean(R1) *0.25 ) );
        cs2=Msym > (0.4 );
        cs =    cs1 .* cs2;   
        if ( posedge == 0 )
             val0 = 1;val1 = 0;
             val_off =0;
             signal_val1 = 2;
             signal_val0 = 2400;
        else            
            if ( sim.cfotype == 8 )
                val1 = 68; signal_val1  = 70;
                val0 = 3; signal_val0 = 5;                 
                cs2=Msym > (0.5 );
                cs=cs2;
            else
                val1 = 98; signal_val1  = 100;
                val0 = 3; signal_val0 = 16;
            end
            val_off= + len/2 ;
        end   
        [idx1, idx2 ] = SearchCS( cs ,search_idx, val0, signal_val0,  val1, signal_val1, val_off , break_en );    
    end

    %% Fixed simulation - Single frequency CFO based on CRT using 2/1 training symbol
    if ( sim.fixed_sim == 1 && (sim.cfotype == 5 || sim.cfotype == 8 ))
        input_length = round( length(in));
        search_idx=100; val0 = 0;val1 = 32;
        val_off = 16;signal_val1  = 32;signal_val0=1;break_en=1;
        for isample=search_idx+1:step:input_length-2*len;  
            P = in(isample+k) .* conj(in(isample+len+k));
            R = abs(in( isample +k ))  .^2;
            P = Change_fixed_bit2( P, sim.CSMulOutbit, 1 );
            R = Change_fixed_bit2( R, sim.CSMulOutbit, 1 );
            
            P1(isample) = sum( P )  ;
            R1(isample) = sum( R )  ;              
            P1(isample  ) = Change_fixed_bit2( P1(isample), sim.CSSumOutbit, 1 );
            R1(isample  ) = Change_fixed_bit2( R1(isample), sim.CSSumOutbit, 1 );
            
            if ( sim.CSAppr == 0 )
                P1(isample:isample+step-1 ) = abs( P1(isample  )) .^2;
                R1(isample:isample+step-1 ) = R1(isample  ) .^2;
                Msym(isample:isample+step-1) =  P1(isample)/  R1(isample);
                cs2(isample:isample+step-1) = Msym(isample:isample+step-1) > cs_th; %  Opt
            else
                P1(isample:isample+step-1 ) = abs( real(P1 (isample) )) +abs( imag(P1 (isample) ))  ;
                R1(isample:isample+step-1 ) =  R1(isample  )  ;
                Msym(isample:isample+step-1) =  P1(isample)/  R1(isample);
                cs2(isample:isample+step-1) = Msym(isample:isample+step-1) > sqrt(cs_th); %  Opt
            end
            
        end
        if (sim.ADCbit == 0 )
            cs1= R1 >  2e-5;
        else
            if ( sim.CSAppr == 0 )
                cs1 = R1 > (2^(sim.CSInbit *2) * size(k,2) * 0.05 * 0.25 )^2;% 1e3; 
            else
                cs1 = R1 > (2^(sim.CSInbit *2) * size(k,2) * 0.05 * 0.25 ) ;% 1e3; 
            end
        end
        cs =  cs1 .* cs2;
        [idx1, idx2 ] = SearchCS( cs ,search_idx, val0, signal_val0,  val1, signal_val1, val_off , break_en ); 
    end
    %% Zhou's algorithm  
    if ( sim.cfotype == 2 )
        len=64;
        k = 1:len;
        [P1, R1, Msym, R2] = AutoCorr( in ,search_idx, 16, params.repSTF  );         
        break_en=1;        
        cs=Msym > (0.25 );           
        val0 = 1;    signal_val0 = 16;
        val1 = 99;   signal_val1  = 100;
        val_off= 0 ;       
        [idx1, idx2 ] = SearchCS( cs ,search_idx, val0, signal_val0,  val1, signal_val1, val_off , break_en );    
    end
    
    %% CFO (EEO)
    if ( sim.cfotype == 7 )
        for isample=search_idx+1+2*len :input_length-2*len;     
            P1(isample)= sum( in(isample+k) .* conj(in(isample- len + k )));
            R1(isample) = sum (abs( in ( isample +k )) .^2 );     
            Msym(isample) =  abs( P1(isample) ) ^2 / R1(isample) ^2 ;   
            R2(isample) =   (abs( in ( isample   )) .^2 );   
        end
      posedge = 0;
      cs1=( R2 >  (mean(R2) *0.1 ) );
      cs2=Msym > (0.4 );
      cs =   cs2;%cs1 .* cs2; 
      posedge = 1;
       break_en=1;
     if ( posedge == 0 )
             val0 = 1;val1 = 0;
             val_off =0;
             signal_val = 2;
             signal_val0 = 2400;
     else
         val1 = 98; signal_val1  = 100;
                 val0 = 3; signal_val0 = 16;
             val_off= -len/2; 
         end
        [idx1, idx2 ] = SearchCS( cs ,search_idx, val0, signal_val0,  val1, signal_val1, val_off , break_en );    
    end
    
    %% 
    idx3(istream) = idx2;
    %% Draw the figure        
    if ( en_plot == 1 )         
          CSFigure( in, cs, Msym, idx1, idx2)
    end 
end

idx = min( idx3) ;    

end


