function [idx_sync, MaxVal] = NRxFindSync( in , sim, params, en_plot )
    
    idx_sync =1;   
    sim.cross_sync = 0;

    %% Zhou's algorithm  
    if ( sim.cfotype == 2 )
        N= params.lenSTF;  

        k2 = -31:32 ; 
        Xcor = [ sim.STF(1,:) sim.LTF(1,1:32)];
        search_range = params.lenSTF*params.NSTF+(-16:16) ; 
        [P2, R2, Msym] = CrossCorr( in, Xcor, search_range, k2 );  
        cs =  Msym == max( Msym );
        idx = find ( Msym == max( Msym ) );
        idx_sync = idx  -params.lenSTF*params.NSTF;
        MaxVal = max( Msym );
    end
    %% Conventional CFO based on CRT
    if ( sim.cfotype == 4 )
        N= params.lenSTF; 
        k=0:N-1;
        k1=0:2*N-1;
        k2 = -31:32 ; 
        Xcor = [ sim.STF( size(sim.STF,2)-15:size(sim.STF,2)), sim.LTF(1,1:16)];
        Xcor = [ sim.STF(1,:), sim.LTF(1,1:32)];
        search_range = params.lenSTF*params.NSTF+(-N/2 :N/2 ) ;

        for istream=1:size(in,1)
            [P2, R2, Msym(istream,:)] = CrossCorr( in(istream,:), Xcor, search_range, k2 ); 
        end
        Msym = sum(Msym,1);
        cs = (Msym==max(Msym));
        idx = find ( Msym == max( Msym ) );
        idx_sync = idx  - params.lenSTF*params.NSTF ; 
        MaxVal = max( Msym );
    end
    %% Single frequency CFO based on CRT using 2/1 training symbol
    if ( sim.cfotype == 5 || sim.cfotype == 8) 
        search_range = params.lenSTF*params.NSTF+(-32:32);

        k2 = 1:64 ;      
        Xcor = [  sim.LTF(1,1:64)];
        in1=in;
        if ( sim.FSInbit ~= 0 )  
            k2 = 1:32 ; 
            in1 = Change_fixed_bit2( in, sim.FSInbit, sim.ADCbit- sim.FSInbit -1  ); 
            Xcor = sim.LTF(1,1:32)/max(abs(sim.LTF(1,1:32))) * (2^(sim.FSInbit-1)+2);
            Xcor= Change_fixed_bit2( Xcor, sim.FSInbit, 0 ); 
            search_range = params.lenSTF*params.NSTF+(-16:32);
            if ( sim.FSEst == 1 )    
                max_idx_set = [];
                est_step = 4 ;
                for d=1:size(search_range  ,2)
                    Xcor1=Change_fixed_bit2( Xcor,2,0);
%                     in2=Change_fixed_bit2( in1(:,search_range(d)+k2),1,0);
                    in2 = ((in1(:,search_range(d)+k2) ) > 0 )* 2-1;
                    P      =  [Xcor1 ;Xcor1 ;]  .* conj(in2);                
%                     Msym1(d) =  sum(abs(sum(P,2)  ) .^2);
                    Msym1(d) =  sum(abs(real(sum(P,2)))+abs(imag(sum(P,2))));
                    if ( mod(d,4) == 0 ) 
                        a=find( max(Msym1(d-est_step+1:d)) == Msym1(d-est_step+1:d)); 
                        max_idx_set = [max_idx_set, d-est_step+a(1)+search_range(1)-1];          
                    end
                end
                search_range = max_idx_set;
            end
        end
        for istream=1:size(in1,1)
        [P2(istream,:), R2, Msym(istream,:)] = CrossCorr( in1(istream,:), Xcor, search_range, k2  ); 
        end
        if ( sim.FSSumOutbit ~= 0 ) 
            Msym = sum(P2,1);
            idx = find ( Msym == max( Msym ) );
        else
            Msym = sum(Msym,1);
            idx = find ( Msym == max( Msym ) );
        end
        idx_sync =idx-params.lenSTF*params.NSTF ;%-(params.NFFT*params.CPratio)-1;
        MaxVal=max( Msym );
        cs = Msym >= MaxVal;
    end
    %% 
    if ( sim.cfotype == 9 )
        N=16*4;
        k=0:N/4-1;

        for d=129:128+params.lenSTF
            P1(d) = sum ( conj( in(d+k+N/2) ) .* in( d + k + N/2 + N/4)  +  ...
                    conj( in(d+k ) ) .* in( d + k   + N/4) ) ;
            R1(d) = sum (abs( in ( d+k+ N/4 )) .^2 ) + sum (abs( in ( d-k+ N/4 )) .^2 ) ;          

            Msym(d) =  abs( P1(d) ) ^2 / R1(d) ^2 ;
        end      
        idx = find ( Msym == max( Msym ));

    end
     %% CFO (EEO)
    if ( sim.cfotype == 7 )
        N=params.NFFT;
        k=0:N/2-1;
        k1=0:N-1;
        search_range = params.lenSTF*params.NSTF+(1:N/2);
        for istream=1:size(in,1)
            in1=in(istream,:);
            for d=search_range
                P1(d) = sum ( conj( in1(d+k) ) .* in1( d + k + N/2 ));
                R1(d) = sum (abs( in1 ( d+k1)) .^2 );            
                P2(d) = sum ( conj( in1(d+(-16:15)+ N/2) ) .* sim.LTF );  
%                     Msym(d) =  abs( P1(d) ) ^2   / R1(d) ^2 ;
%                     Msym(istream, d) =  abs( P1(d) ) ^2 * abs( P2(d) ) ^2 / R1(d) ^4 ;
                Msym(istream, d) =   abs( P2(d) ) ^2 ;
            end      
        end
        Msym = sum(Msym,1);
        idxlist = find ( Msym == max( Msym )  );
        idx = round(( idxlist(size(idxlist,2))+idxlist(1) )/2);
        idx_sync =idx-(params.NFFT*params.CPratio)-1;
        idx_sync =idx-(params.NFFT*params.CPratio)-1-params.lenSTF*params.NSTF ;

        MaxVal = max( Msym );
        cs = Msym >= MaxVal;
    end
    %% Draw the figure        
    if ( en_plot == 1 )         
         CSFigure( in, Msym, Msym, idx, idx)
    end  
    
end 