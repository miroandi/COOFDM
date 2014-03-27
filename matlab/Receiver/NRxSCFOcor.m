function [ cfo_phase, cfo_phase_16, cfo_phase_17]= NRxSCFOcor( in, params, sim  )   

    tsize =params.lenSTF;
    STFidx=tsize*( params.NSTF);
    STF = in(1, 1:STFidx); 
    STF1 = in(1, 1:STFidx); 
    if ( sim.CFOinbit ~= 0 )          
        STF1 = Change_fixed_bit2( in, sim.CFO1inbit, sim.ADCbit- sim.CFO1inbit   );  
        STF  = Change_fixed_bit2( in, sim.CFOinbit, sim.ADCbit- sim.CFOinbit-1   );  
    end
    %% Carrier frequency offset estimation using Short preamble 
    if ( sim.enSCFOcomp == 0 )
        cfo_phase = 0 ;
        cfo_phase_16 = 0 ;
        cfo_phase_17 = 0 ;
    else 
        if ( STFidx == 0 )
              cfo_phase = 0 ;
        else
            %% CFO (EEO)
            if (sim.cfotype == 7 && params.MIMO_emul == 0 )
                repsize = params.repSTF ;
                totlen = params.lenSTF * params.NSTF ;
                STFoffset = (STF(STFidx-totlen+1+repsize:STFidx)  .* ...
                    conj (STF(STFidx -totlen+1:STFidx-repsize ) ))  ;
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);

                cfo_phase = Change_fixed_bit_lim( angle(sum(STFoffset)), sim.ATANbit, pi)/(repsize) ;         
                cfo_phase_16 = cfo_phase;
                cfo_phase_17 = cfo_phase;
            end
            %% Zhou's algorithm
            if (sim.cfotype == 2 || (sim.cfotype == 7 && params.MIMO_emul == 1) )
%                 STFoffset = (STF(STFidx-params.NFFT*params.RxOVERSAMPLE+1+params.repSTF:STFidx)  .* ...
%                 conj (STF(STFidx -params.NFFT*params.RxOVERSAMPLE+1:STFidx-params.repSTF ) ))  ;
                gd=40;
                STFoffset = (STF(gd+1+params.repSTF:STFidx-gd)  .* ...
                conj (STF(gd+1:STFidx-params.repSTF-gd ) ))  ;
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);

                cfo_phase = Change_fixed_bit_lim( angle(sum(STFoffset)), sim.ATANbit, pi)/(params.repSTF) ;         

                
                % A simple and frequency offset estimation ... 
                
                repsize = params.NFFT*params.RxOVERSAMPLE ;
                if (sim.cfotype == 7 && params.MIMO_emul == 1)
                    repsize = repsize / 2 ;
                end
                STFoffset1 = (STF(STFidx-repsize+1:STFidx)  .* ...
                conj (STF(STFidx-repsize*2+1:STFidx-repsize ) ))   ;

                f_FFO =  Change_fixed_bit_lim( ...
                angle(sum(STFoffset1)), sim.ATANbit, pi)/repsize ;

                sc_angle = params.NFFT/2/pi ;
                if (sim.cfotype == 7 && params.MIMO_emul == 1)
                    sc_angle = params.NFFT/pi ;
                end
                f_est1 = round(cfo_phase*(sc_angle ))/(sc_angle) +  f_FFO  ;  
                cfo_phase = round ( (cfo_phase-f_est1)*sc_angle )/(sc_angle)  + f_est1   ; 
                cfo_phase_16 = cfo_phase;
                cfo_phase_17 = cfo_phase;
                
            end
            %% Conventional 
            if (sim.cfotype == 3 )
                sc_angle = params.repSTF * params.rep2STF/2/pi;
                rep=params.repSTF;            
                ini=10; ini2=tsize+ini;
                STFoffset = ( [ STF(ini+rep+1:ini+rep*2)  STF(ini2+rep+1:ini2+rep*2)] .* ...
                 conj ([ STF(ini+ 1:ini+rep*1)  STF(ini2+ 1:ini2+rep*1)]) );     
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);
                cfo_phase_1  = Change_fixed_bit_lim( angle(sum(STFoffset)), sim.ATANbit, pi); %/(rep) 

                rep=params.rep2STF;      ini=72+8; ini2=tsize+ini;
                STFoffset1 = ( [ STF(ini+rep+1:ini+rep*2)  STF(ini2+rep+1:ini2+rep*2)] .* ...
                 conj ([ STF(ini+ 1:ini+rep*1)  STF(ini2+ 1:ini2+rep*1)]) );
                STFoffset1 = Change_fixed_bit(STFoffset1, sim.MulOutbit);
                cfo_phase_2  = Change_fixed_bit_lim( angle(sum(STFoffset1)), sim.ATANbit, pi); %/(rep)

                out_int1 = round(cfo_phase_1*(params.rep2STF/2/pi)) 
                out_int2 = round(cfo_phase_2*(params.repSTF/2/pi)) 
                f_FFO = 0.5*(cfo_phase_1 -  out_int1/sc_angle + cfo_phase_2 - out_int2/sc_angle)

                [cfo_phase , int1, int2] = get_crt_9_16( out_int1, out_int2);
%                 if ( sim.showinteger  == 1 )
                    cfo_phase_16 =  out_int1;  
                    cfo_phase_17 =  out_int2; 
%                 end
            
                cfo_phase= cfo_phase/sc_angle  +f_FFO 
            end
            %% Conventional CFO based on CRT  
            if (sim.cfotype == 4  )
                sc_angle = params.repSTF * params.rep2STF/2/pi;
                rep=params.repSTF;            
                ini=rep*3; ini2=tsize+ini;
                stfidx=[(ini+rep+1:ini+rep*4), (ini2+rep+1:ini2+rep*4)];
                STFoffset = (  STF(stfidx) .* conj ( STF(stfidx - rep)));  
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);
                STFoffset = Change_fixed_bit(sum(STFoffset), sim.ATANINbit);
                cfo_phase_1  = Change_fixed_bit_lim( sc_angle* angle(STFoffset), sim.ATANbit, sc_angle*pi)/(rep);

                rep=params.rep2STF; ini=params.repSTF*8+8; ini2=tsize+ini;
                stfidx=[(ini+rep*2+5:ini+rep*4), (ini2+rep*2+5:ini2+rep*4)];
                STFoffset1 = (  STF(stfidx) .* conj ( STF(stfidx - rep)));
                STFoffset1 = Change_fixed_bit(STFoffset1, sim.MulOutbit);
                STFoffset1 = Change_fixed_bit(sum(STFoffset1), sim.ATANINbit);
                cfo_phase_2  = Change_fixed_bit_lim( sc_angle*angle(STFoffset1), sim.ATANbit, sc_angle*pi)/(rep);

                % A simple and frequency offset estimation ... 
                stfidx=STFidx-tsize+1:STFidx;
                STFoffset2 = (STF(stfidx)  .*  conj (STF(stfidx-tsize ) ));                     ;
                STFoffset2 = Change_fixed_bit(STFoffset2, sim.MulOutbit);
                STFoffset2 = Change_fixed_bit(sum(STFoffset2), sim.ATANINbit);
                f_FFO =  Change_fixed_bit_lim( sc_angle*angle(STFoffset2), sim.ATANbit, sc_angle*pi)/(tsize)   ;  

                [ cfo_phase_16, out_int1, out_frac1 ] = Get_int( cfo_phase_1, f_FFO,  1 ) ;            
                [ cfo_phase_17, out_int2, out_frac2 ] = Get_int( cfo_phase_2, f_FFO,  1 ) ; 
                [cfo_phase , int1, int2] = get_crt_9_16( out_int1, out_int2);
                if ( sim.showinteger  == 1 )
                    cfo_phase_16 =  int1;%cfo_phase_1;
                    cfo_phase_17 =  int2;%cfo_phase_2;
                end
            
                 cfo_phase= cfo_phase/sc_angle  + f_FFO/sc_angle;
                 cfo_phase=Change_fixed_bit_lim( cfo_phase, sim.ATANbit, pi);
            end
           %% Single frequency CFO based on CRT using 2/1 training symbols
            if (sim.cfotype == 5 && sim.fixed_sim == 0 || sim.cfotype == 8 )
                tsize =params.lenSTF * params.NSTF ;
                sc_angle = params.repSTF * params.rep2STF/2/pi;
                rep=params.repSTF;            
                ini=rep*2;  
                repnum=12;repnum_1=repnum-1;
                gd=15;
 
                STFoffset = STF(gd+rep+1:STFidx-gd) .* conj (  STF(gd+1:STFidx-gd-rep) );
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);
                STFoffset = Change_fixed_bit(STFoffset*exp(- ( 1j)*(sim.tone - 1) *rep*pi*2/params.NFFT), sim.MulOutbit);
                STFoffset = Change_fixed_bit(sum(STFoffset), sim.ATANINbit);
                cfo_phase_1  = Change_fixed_bit_lim( sc_angle*angle(STFoffset), sim.ATANbit,sc_angle* pi)/(rep);

                rep=params.rep2STF;  
                repnum=14;repnum_1=repnum-1; 
                STFoffset1 =  STF(gd+rep+1:STFidx-gd) .* conj ( STF(gd+1:STFidx-gd-rep) );
                STFoffset1 = Change_fixed_bit(STFoffset1, sim.MulOutbit);
                STFoffset1 = Change_fixed_bit(STFoffset1*exp(-( 1j )*(sim.tone - 1)*rep*pi*2/params.NFFT), sim.MulOutbit);
                STFoffset1 = Change_fixed_bit(sum(STFoffset1), sim.ATANINbit);
                cfo_phase_2  = Change_fixed_bit_lim( sc_angle*angle(STFoffset1), sim.ATANbit, sc_angle*pi)/(rep);
                
               
                % A simple and frequency offset estimation  
                rep =  params.repSTF * params.rep2STF; 
                gd1= 15;
                gd=  15; 
                STFoffset2 =  STF(gd1+rep+1:STFidx-gd) .* conj ( STF(gd1+1:STFidx-gd-rep) );
                STFoffset2 = Change_fixed_bit(STFoffset2, sim.MulOutbit);
                STFoffset2 = Change_fixed_bit(STFoffset2*exp(-( 1j )*(sim.tone - 1)*rep*pi*2/params.NFFT), sim.MulOutbit);
                STFoffset2 = Change_fixed_bit(sum(STFoffset2), sim.ATANINbit);
                f_FFO =  Change_fixed_bit_lim( sc_angle*angle(STFoffset2), sim.ATANbit, sc_angle*pi)/(rep)   ;  

                [ cfo_phase_16, out_int1, out_frac1 ] = Get_int( cfo_phase_1, f_FFO,  1 ) ;            
                [ cfo_phase_17, out_int2, out_frac2 ] = Get_int( cfo_phase_2, f_FFO,  1 ) ; 

                if ( params.rep2STF  == 8)
%                     [ cfo_phase , int1, int2] = get_crt_7_8( out_int1, out_int2);
                    [ cfo_phase , int1, int2] = get_crt_9_8( out_int1, out_int2);
%                   [ cfo_phase , int1, int2] = get_crt_11_8( out_int1, out_int2);
                    
                end 
                if ( params.rep2STF  == 16 )
                    [ cfo_phase , int1, int2] = get_crt_9_16( out_int1, out_int2);
                end
                if ( params.rep2STF  == 4 )
                    [ cfo_phase , int1, int2] = get_crt_7_4( out_int1, out_int2);
                end
                
                if ( sim.showinteger  == 1 )
                    cfo_phase_16 =  int1;%cfo_phase_1;
                    cfo_phase_17 =  int2;%cfo_phase_2;
                end
                cfo_phase= cfo_phase/sc_angle  + f_FFO/sc_angle;
                cfo_phase =  Change_fixed_bit_lim( cfo_phase, sim.ATANbit, pi);
                cfo_phase_16 = cfo_phase;
%                 figure; plot(complex(real(STF), imag(STF))); 
%                  a=1.1*max(max(abs(real(STF))),max(abs(imag(STF))));
%                     ylim([-a a ]);xlim([-a a ])
            end
            %% Fixed simulation 
        if ((sim.cfotype == 5 && sim.fixed_sim == 1 ))
            gd =16;
            STFidx=tsize*2; % Number of sample 
            sc_angle = params.repSTF * params.rep2STF/2/pi;
            rep=params.repSTF;   
            STFoffset = (STF1(gd+rep+1:STFidx-gd)  .*  conj (STF1(gd+1:STFidx-gd-rep) )); 
            STFoffset = Change_fixed_bit2(     STFoffset, sim.CFO1MulOutbit, 0);
%             STFoffset = Change_fixed_bit2(sum(STFoffset * exp(-1i*0.7854)), sim.CFO1SumOutbit, 0); 
            STFoffset = Change_fixed_bit2(sum(STFoffset), sim.CFO1SumOutbit, sim.CFO1MulOutbit+7-sim.CFO1SumOutbit);    
            cfo_phase_1  = Change_fixed_bit_lim( angle(STFoffset) , sim.CFObit,  pi);
            cfo_phase_1  =cfo_phase_1 - 0.7854;
             if ( cfo_phase_1 >= pi )
                cfo_phase_1 = cfo_phase_1-2*pi;
             end    
            if ( cfo_phase_1 <= -pi )
                cfo_phase_1 = cfo_phase_1+2*pi;
            end  
            cfo_phase_1  = Change_fixed_bit_lim( sc_angle*(cfo_phase_1)/(rep), sim.CFObit,params.rep2STF/2) ;

            rep=params.rep2STF; % 112 9+7 
            STFoffset1 = (STF1(gd+rep+1:STFidx-gd)  .*  conj (STF1(gd+1:STFidx-gd-rep) )); 
            STFoffset1 = Change_fixed_bit2(STFoffset1, sim.CFO1MulOutbit, 1);
            STFoffset1 = Change_fixed_bit2(sum(STFoffset1), sim.CFO1SumOutbit, sim.CFO1MulOutbit+7-sim.CFO1SumOutbit);            
            cfo_phase_2  = Change_fixed_bit_lim( angle(STFoffset1) , sim.CFObit,  pi);  
%             cfo_phase_2  = sc_angle*(cfo_phase_2)/rep ;
            cfo_phase_2  = Change_fixed_bit_lim( sc_angle*(cfo_phase_2)/rep, sim.CFObit,params.repSTF/2) ; 


            % A simple and frequency offset estimation .. 
            rep = params.rep2STF  * params.repSTF ;
            STFoffset2 = (STF(gd+rep+1:STFidx-gd)  .*  conj (STF(gd+1:STFidx-gd-rep) )); 
            STFoffset2 = Change_fixed_bit2(STFoffset2, sim.CFOMulOutbit, 1);
            STFoffset2 = Change_fixed_bit2(sum(STFoffset2), sim.CFOSumOutbit, sim.CFOMulOutbit+7-sim.CFOSumOutbit);            
            f_FFO  = Change_fixed_bit_lim( angle(STFoffset2) , sim.CFObit,  pi); 
            f_FFO  = Change_fixed_bit_lim( sc_angle*(f_FFO)/(rep), sim.CFObit,1/2) ;

            if (  sim.cfotype == 8  )
                f_FFO =( cfo_phase_1-round(cfo_phase_1) +cfo_phase_2-round(cfo_phase_2))/2;
                f_FFO = cfo_phase_1-round(cfo_phase_1);
            end

            [ cfo_phase_16, out_int1, out_frac1 ] = Get_int( cfo_phase_1, f_FFO,  1 ) ;            
            [ cfo_phase_17, out_int2, out_frac2 ] = Get_int( cfo_phase_2, f_FFO,  1 ) ; 

            % integer 
            if ( params.rep2STF  == 8)
                [ cfo_phase , int1, int2] = get_crt_9_8( out_int1, out_int2);
            else
                [ cfo_phase , int1, int2] = get_crt_9_16( out_int1, out_int2);
            end
            if (  sim.cfotype == 8  )
                [ cfo_phase , int1, int2] = get_crt_33_16( out_int1, out_int2);
            end

            cfo_phase= cfo_phase/sc_angle  + f_FFO/sc_angle;
            cfo_phase =  Change_fixed_bit_lim( cfo_phase, sim.CFObit, pi);
            cfo_phase_17 = f_FFO;
        end
            
            %%
            if (sim.cfotype == 6 )
                 
                rep=params.repSTF;            
                ini=rep*2; ini2=tsize+ini;
                STFoffset = ( [ STF(ini+rep+1:ini+rep*8)  ] .* conj ([ STF(ini+ 1:ini+rep*7)  ]) );     
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);
                cfo_phase_1  = Change_fixed_bit_lim( angle(sum(STFoffset)), sim.ATANbit, pi)/(rep);

                rep=params.rep2STF;      ini=params.lenSTF/2; ini2=tsize+ini;
                STFoffset1 = ( [ STF(ini+rep+1:ini+rep*5)  ] .* conj ([ STF(ini+ 1:ini+rep*4)  ]) ); 
                STFoffset1 = Change_fixed_bit(STFoffset1, sim.MulOutbit);
                cfo_phase_2  = Change_fixed_bit_lim( angle(sum(STFoffset1)), sim.ATANbit, pi)/(rep);

                L1= 8; L2=5;
                N1=128; 
                F_sig = L2-L1;
                N2 = floor(128/25)*25 ;
                L2_prime = N1*L2/N2;
                P2 = F_sig*round(cfo_phase_1-cfo_phase_2);
                e2 = P2* L2_prime+ cfo_phase_2;
                P1=P2;
                if ( abs(e2) >= L1*L2/2) 
                    if ( cfo_phase_1 > cfo_phase_2)
                        P1 = F_sig*round(cfo_phase_1-cfo_phase_2-L2_prime);
                        e2 = L2_prime*(P1 +1 ) + cfo_phase_2;
                    else
                        P1 = F_sig*round(cfo_phase_1-cfo_phase_2+L2_prime);
                         e2 = L2_prime*(P1 -1 ) + cfo_phase_2;
                    end
                    
                end
               e1 = L1*P1 + cfo_phase_1;
               cfo_phase_16 =e1;
               cfo_phase_17 =e2;
               cfo_phase =(e1+e2) /2;
                 %cfo_phase = Change_fixed_bit_lim( angle(sum(STFoffset)), sim.ATANbit, pi)/(rep);%params.repSTF) ;         
            end
            if (sim.cfotype == 9 )
                sc_angle = params.repSTF * params.rep2STF/2/pi;
                rep=params.repSTF;            
                ini=rep*2;  
                repnum=5;repnum_1=repnum-1;
                STFoffset = STF(ini+rep+1:ini+rep*repnum) .* ...
                     conj (  STF(ini+ 1:ini+rep*repnum_1) );
                STFoffset = Change_fixed_bit(STFoffset, sim.MulOutbit);
                STFoffset = Change_fixed_bit(sum(STFoffset), sim.ATANINbit);
                cfo_phase_1  = Change_fixed_bit_lim( sc_angle*angle(STFoffset), sim.ATANbit,sc_angle* pi)/(rep);

                
                ini = rep *2 + params.lenSTF;
                rep=params.rep2STF;  % repnum= 4;repnum_1=repnum-1;   
                repnum=14;repnum_1=repnum-1;
                STFoffset1 =  STF(ini+rep+1:ini+rep*repnum) .* ...
                     conj ( STF(ini+ 1:ini+rep*repnum_1) );

                STFoffset1 = Change_fixed_bit(STFoffset1, sim.MulOutbit);
%                 STFoffset1 = Change_fixed_bit(STFoffset1*exp(-( 1j )*(sim.tone - 1)*rep*pi*2/params.NFFT), sim.MulOutbit);
                STFoffset1 = Change_fixed_bit(sum(STFoffset1), sim.ATANINbit);
                cfo_phase_2  = Change_fixed_bit_lim( sc_angle*angle(STFoffset1), sim.ATANbit, sc_angle*pi)/(rep);
                
               
                % A simple and frequency offset estimation ..
                ini =16; ini2= ini + params.lenSTF;
                tsize = tsize/2;
                
                STFoffset2  = -(STF(params.lenSTF-tsize+1+ini:params.lenSTF)  .*  conj (STF(params.lenSTF-2*tsize+1+ini:params.lenSTF-tsize) )) ;
                 
                
                STFoffset2 = Change_fixed_bit(STFoffset2, sim.MulOutbit);
%                 STFoffset2 = Change_fixed_bit(STFoffset2*exp(-( 1j )*(sim.tone - 1)*tsize*pi*2/params.NFFT), sim.MulOutbit);
                STFoffset2 = Change_fixed_bit(sum(STFoffset2), sim.ATANINbit);
                f_FFO =  Change_fixed_bit_lim( sc_angle*angle(STFoffset2), sim.ATANbit, sc_angle*pi)/(tsize)   ;  
                

                [ cfo_phase_16, out_int1, out_frac1 ] = Get_int( cfo_phase_1, f_FFO,  1 ) ;            
                [ cfo_phase_17, out_int2, out_frac2 ] = Get_int( cfo_phase_2, f_FFO,  1 ) ; 

                [ cfo_phase , int1, int2] = get_crt_9_8( out_int2, out_int1);
                if ( sim.showinteger  == 1 )
                    cfo_phase_16 =  int1;%cfo_phase_1;
                    cfo_phase_17 =  int2;%cfo_phase_2;
                end
                cfo_phase= cfo_phase/sc_angle  + f_FFO/sc_angle;
                cfo_phase =  Change_fixed_bit_lim( cfo_phase, sim.ATANbit, pi);
                cfo_phase_16 = cfo_phase;
            end
        end
       
    end 
end   