function [sim_new, params_new] = InitCFO( sim, params )

    sim_new =sim;
    params_new = params;
    if ( sim.cfotype == 1 )
        % Current design 
        params_new.one_stf =1 ;
        params_new.repSTF = 16;
        params_new.lenSTF =128;

        params_new.NSTF = 0;
    end 
    % Ref[2]
    if ( sim.cfotype == 2 )
        % Current design 
        params_new.one_stf =1 ;
        params_new.repSTF = 4;%16;
        params_new.lenSTF =128;
        params_new.NSTF = 2;
        params_new.NLTF = 1;
    end 
    %Idea 2
    if ( sim.cfotype == 3 )
        % No fine CFO 
        params_new.one_stf = 0 ;
        params_new.repSTF = 31;
        params_new.rep2STF = 32;
        params_new.lenSTF = 144;
        params_new.NSTF = 2;
    end 
     %Idea 1
    if ( sim.cfotype == 4  || sim.cfotype == 5 )
        
        params_new.one_stf =0 ;
        params_new.repSTF = 9;
        params_new.rep2STF = 16;
        params_new.lenSTF =params_new.NFFT*(1+params_new.CPratio);
        params_new.NSTF = 2;
        params_new.NLTF = 1;
        params_new.RxSTFidx= params_new.lenSTF*params_new.RxOVERSAMPLE*params_new.NSTF;
    end 
    if (   sim.cfotype == 8 )
        
        params_new.one_stf =0 ;
        params_new.repSTF = 9;
        params_new.rep2STF = 8 ;
        params_new.lenSTF =params_new.NFFT*(1+params_new.CPratio);
        params_new.NSTF = 1;
        params_new.NLTF = 1;
        params_new.RxSTFidx= params_new.lenSTF*params_new.RxOVERSAMPLE*params_new.NSTF;
    end 
    % Ref[7] a high performance .
    if ( sim.cfotype == 6 )
        params_new.one_stf =0 ;
        params_new.repSTF = 16; % 128/8
        params_new.rep2STF = 25; % 128/5
        params_new.lenSTF =288;
        params_new.NSTF = 1;
        params_new.NLTF =0;
    end 
    if ( sim.cfotype == 7 )
        
        params_new.one_stf =1 ;
        params_new.repSTF = 4;%16;
        params_new.lenSTF =128;
        
        params_new.lenSTF =params_new.NFFT * (params_new.CPratio +1);
        params_new.NSTF = 1; 
        params_new.NLTF =1;
    end 
    
%     if ( sim.cfotype == 8 ) % Schmidl & Cox 
%         params_new.one_stf =0 ;
%         params_new.repSTF = 16; % 128/8
%         params_new.rep2STF = 25; % 128/5
%         params_new.lenSTF =288;
%         params_new.NSTF = 0;
%         params_new.NLTF =1;
%     end 
    
    if ( sim.cfotype == 9 ) 
        params_new.one_stf =0 ;
        params_new.repSTF = 8;
        params_new.rep2STF = 9 ;
        params_new.lenSTF =params_new.NFFT*(1+params_new.CPratio);
        params_new.NSTF = 2;
        params_new.NLTF = 1;
        params_new.RxSTFidx = ...
        params_new.lenSTF*params_new.RxOVERSAMPLE*params_new.NSTF;
    end 
    
    switch ( sim_new.cfotype )
        
        case {9}         
            sim_new.enCFOcomp= 0 ;
            sim_new.enSCFOcomp= sim.CFOcomp_en  ; 
            sim_new.cfotype_str = [ 'Proposed 2'] ; 
        case {8}         
            sim_new.enCFOcomp= 0 ;
            sim_new.enSCFOcomp= sim.CFOcomp_en  ; 
            sim_new.cfotype_str = [ 'Proposed TS1'] ; 
        case {5}         
            sim_new.enCFOcomp= 0 ;
            sim_new.enSCFOcomp= sim.CFOcomp_en  ; 
            sim_new.cfotype_str = [ 'Proposed'] ; 
        case {4}         
            sim_new.enCFOcomp= 0 ;
            sim_new.enSCFOcomp= sim.CFOcomp_en  ; 
            sim_new.cfotype_str = [ 'CRT based'] ; 
        case {2}         
            sim_new.enCFOcomp= 0 ;
            sim_new.enSCFOcomp= sim.CFOcomp_en  ;  
            sim_new.cfotype_str = [ 'Ref.[3] with identical part size of 4'] ; 
        case {7}         
            if ( params.Nstream == 2  )
                sim_new.enCFOcomp= 0   ;
                sim_new.enSCFOcomp= sim.CFOcomp_en  ;  
            else
                sim_new.enCFOcomp= sim.CFOcomp_en  ;
                sim_new.enSCFOcomp= sim.CFOcomp_en ;  
            end
            sim_new.cfotype_str = [ 'EEO'] ; 
        otherwise
            error(['Wrong CFO type ', num2str( sim_new.cfotype)]) 
    end

end