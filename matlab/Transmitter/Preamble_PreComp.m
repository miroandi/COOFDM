function [preamble_out, STF_seq, LTF_seq] = Preamble_PreComp( params, sim );

j=sqrt(-1);

sim1=sim;
sim1.subband=0;

tmp  = GenSTF( params, sim );
tmp0 = GenSTF( params, sim1 );
STFsize=(params.MIMO_emul + params.NSTF)*params.lenSTF;
if ( sim.precomp_en == 2 || sim.precomp_en == 3 )
    STF     = tmp(:, 1:STFsize/sim.subband1); 
    STF_seq = tmp0(:, STFsize-31:STFsize);
else
    STF     = tmp(:, 1:(params.MIMO_emul + params.NSTF)*params.lenSTF);
    STF_seq = tmp0(:, STFsize-31:STFsize);
end

if ( params.Nstream == 2 )
    STF = [STF; STF; ];
end


%% Frequency offset & Window synchronization
[LTF,LTF_seq]= GenLTF( params, sim );
LTF0= GenLTF( params, sim1 );
if ( sim.cfotype == 7)
%     tmp = ifft([ LTFe  ]);
%         LTF_seq=tmp(:, params.NFFT/2+(-15:16));
%     LTF_seq=LTF0(2, params.NFFT/2+(-15:16));
else
    LTF_seq=LTF0(1, 1:64);
end
            
if ( params.NSTF == 0 )
    STF_seq=[];
    STF=[];
end

preamble_out  = [ STF, LTF ];

end

function STF_out= GenSTF( params, sim )
    osdata = zeros(1,  params.NFFT*(params.OVERSAMPLE -1));
    STF_1tone = zeros(1,params.NFFT);
    if (sim.cfotype ==5 || sim.cfotype == 8)
        STF_1tone(sim.tone) = 1; % +1j ;
        % STFt = 1*sqrt(1/2) * ifft( [STF_1tone, osdata] );  
        STFt   = ifft_band( 1/ sqrt(abs(STF_1tone(sim.tone))) *  [STF_1tone, osdata] , params, sim );   
        tmp = [STFt STFt STFt STFt STFt STFt STFt STFt ];
    else
        STFt  = ifft_band([(params.STF), osdata], params, sim );  
        STFt  = sqrt(1/(sum( abs(params.STF) .* abs(params.STF) )))*STFt;

        if ( sim.cfotype == 2 || sim.cfotype == 7)
            tmp1=[];
            for nstf=1:ceil(params.lenSTF*params.OVERSAMPLE/params.repSTF)
                tmp1=[tmp1 STFt(:,1:4:16)];
            end
        elseif ( sim.cfotype == 4 )
            tmp1=[]; tmp2 = [];
            %First, Second STF 
            for nstf=1:8
                tmp1=[tmp1 STFt(:,1:2:8) zeros(size(STFt,1),1)  STFt(:,9:2:16)];
                tmp2=[tmp2 STFt(:,1:16)  ];  
            end
            tmp1 = [tmp1, tmp2];
        end   

        if ( sim.cfotype == 9 )
            tmp1=[]; tmp2 = [];
            STFt1 = [STFt(:,1:2:16),STFt(:,1:2:16)]  ;
            for nstf=1:20
                tmp1=[tmp1 STFt(:,1:2:8) zeros(size(STFt,1),1)  STFt(:,9:2:16)];
                tmp2=[tmp2 STFt1 STFt1 STFt1 STFt1 STFt1 -STFt1  -STFt1 -STFt1 -STFt1];  
            end

            tmp = [ tmp2(:,1:params.OVERSAMPLE*params.lenSTF), ...
                    tmp1(:,1:params.OVERSAMPLE*params.lenSTF)];
        else
             tmp=[];
            for nstf=1:(params.MIMO_emul + params.NSTF) 
                tmp  = [tmp  tmp1(:,1:params.OVERSAMPLE*params.lenSTF)];
            end    

        end    
    end
    STF_out=tmp ;
end


function [LTFo,LTF_seq]= GenLTF( params, sim )
    phasor =  params.phi* ([0:params.NFFT/2-1 -params.NFFT/2:-1]) .^2 ;
    gain=0;%4.3348e+003 ;
    theta = sum(abs(params.LTF).^2 ) *gain*(1/(length(params.SubcarrierIndex) +length(params.Pilot)));
    osdata = zeros(1,  params.NFFT*(params.OVERSAMPLE -1));
    if (  sim.cetype == 7 )
            LTFe = zeros(size(params.LTF));
            LTFo= LTFe;
            LTFo(2:2:size(params.LTF, 2) )= params.LTF(2:2:size(params.LTF, 2));
            LTFe(1:2:size(params.LTF, 2) )= params.LTF(1:2:size(params.LTF, 2));
            LTFet  = ifft_band([ LTFe.* exp(1j* phasor), osdata], params, sim ); 
            LTFot  = ifft_band([ LTFo.* exp(1j* phasor), osdata], params, sim ); 
            LTFet = LTFet * sqrt(1/(sum( abs(LTFe) .* abs(LTFe) ))) ; 
            LTFot = LTFot * sqrt(1/(sum( abs(LTFo) .* abs(LTFo) ))) ; 

            E = [LTFet(:,params.TXLTFCPIndex) LTFet ];
            O = [LTFot(:,params.TXLTFCPIndex) LTFot ];
            E=  circshift(  E, [0, params.CPshift]) ;
            O=  circshift(  O, [0, params.CPshift]) ;
            LTF= [ E O ];
            tmp = ifft([ LTFe.* exp(1j* phasor), osdata]);
            
            if ( params.Nstream == 2 ) 
                LTF =[ E O; ...
                       O E ];       
            end
           %%
           % [ E O E; E E O];
            if ( params.MIMO_emul == 1 ) 
                LTF =[ O E O; E E O];
            else
                if ( params.Nstream == 2 ) 
                LTF =[ O E; ...
                       E O ];       
                end
            end
            tmp = ifft([ LTFe  ]);
            LTF_seq=tmp(:, params.NFFT/2+(-15:16));
    else
        LTFt  = ifft_band([(params.LTF).* exp(j* phasor), osdata], params, sim );  
        LTFt  = sqrt(1/(sum( abs(params.LTF) .* abs(params.LTF) )))*LTFt;
        LTF0= [LTFt(:,params.TXLTFCPIndex) LTFt  ];
        LTF0=  circshift(  LTF0, [0, params.CPshift]) ;

        LTF = [ ];
        for nstf=1:params.NLTF       
            LTF  = [LTF  LTF0];
        end


        if ( params.MIMO_emul == 1 )  

        % [ S S S A A -A D1 D2  ....] 
        % [ Z S S S A A -A  D1 ...
         LTF =[1 * LTF,1 * LTF,  -1 * LTF; ...
               1 * LTF, 1 * LTF,  1* LTF ]; 
        % [ S S S A A -A A D1 D2  ....] 
        % [ Z S S S A A -A A  D1 ...
        else
            if ( params.Nstream == 2 ) 
                LTF =[ params.LTFtype(1,1) * LTF,  params.LTFtype(1,2) * LTF; ...
                       params.LTFtype(2,1) * LTF,  params.LTFtype(2,2) * LTF ];       
            end
        end
        LTF_seq=LTF(1, 1:64);
    end
    LTFo =LTF;
end