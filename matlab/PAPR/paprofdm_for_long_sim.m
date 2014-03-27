function [AvgPAPR, VarPAPR, PAPR]  = paprofdm( MPSK, numOne, nSymbol, sim ) 


%% ParameterSetting 
params.MPSK=  MPSK ;
params.NumSymbol=1;
params.SubcarrierIndex = [-27:-26 -24:-1 1:24 26:27];
params.PilotIndex= [ -30 -25 25 30 ];
params.Pilot = [ -1 1 -1 1 ];
params.OVERSAMPLE = 2 ;
params.FFTSize = 64;
params.CPratio = 1/4;


nBitPerSymbol = 52 * MPSK;
Oversample = params.OVERSAMPLE ;

%% PAPR method selection 
% Select PAPR reduction method
% enSelectiveMapping, enClipping, enScramble
% 0 : NO reduction, Input Sequence vs PAPR analysis 

enScramble = sim.enScramble ;
enClipping = sim.enClipping ; 
enSelectiveMapping = sim.enSelectiveMapping ; 
clipThres = 1.5;
nBit = nSymbol * nBitPerSymbol; 

%% %% HPA Parameter
p = 2 ;
%pa_bkof_dB = 10 ;
pa_bkof_dB = 100;
%VSat = sqrt(10.4709*(10^(pa_bkof_dB/10.0)));
VSat = sqrt(1.04709*(10^(pa_bkof_dB/10.0)));

%% %% Initialization
maxSymbol = 0;
maxPapr = 0;
minSymbol = 40;
minPapr = 40;
avgpower = 0 ;
st = []; % empty vector
paprSymbol= zeros(1, nSymbol);
paprClipped = zeros(1, nSymbol);
paprScramble = zeros(1, nSymbol);

%% Main calculation loop
for indexSymbol = 1:nSymbol

    ip = zeros(1, nBitPerSymbol);
    %ip(1:2:51) = 1 ;
      
    if ( numOne < 0  )  
        ip = getInput( numOne, nBitPerSymbol) ;
    else
        ip = zeros(1, nBitPerSymbol);
        while ( sum(ip) ~= numOne ) 
            ip( floor( rand(1) *nBitPerSymbol )+1) = 1 ;
        end
    end
   
    outputiFFT = ofdm(ip, params);
    % computing the peak to average power ratio for each symbol
    paprSymbol(indexSymbol) = getPapr( outputiFFT ) ;
    avgpower = avgpower + outputiFFT  * outputiFFT'/length(outputiFFT) ;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Scrambler
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ( enScramble == 1 ) 
        ipScramble = getScramble(ip);
        outputScramble = ofdm(ipScramble, params) ;
        % computing the peak to average power ratio for each symbol
        paprScramble(indexSymbol) = getPapr( outputScramble ) ;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Clipping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ( enClipping == 1 ) 
        %outputClipped = max( min( real(outputiFFT), clipThres ) , -clipThres );
        outputClipped = outputiFFT ;
        absoutputiFFT = (outputiFFT .* conj (outputiFFT ));
        for clipi=1:length(outputiFFT)
            if ( absoutputiFFT(clipi) > clipThres) 
                outputClipped(clipi) = outputClipped(clipi) * clipThres/absoutputiFFT(clipi) ;
            end
        end
        
        if ( outputClipped ~= outputiFFT )
            abs( outputClipped - outputiFFT );
        end
       
        paprClipped(indexSymbol) = getPapr( outputClipped ) ; 
    end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Selective Mapping
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    if ( enSelectiveMapping == 1 ) 
        minPapr_tmp =100; minPhase=0;maxStep=40;
        for phase=0:1:maxStep
            ip_tmp = ip + 1i/2*phase/maxStep; 
             outputSelectiveMapping= ofdm(ip_tmp, params );
             paprTmp = getPapr( outputSelectiveMapping ) ;
             if ( minPapr_tmp > paprTmp ) 
                 minPapr_tmp = paprTmp;
                 minPhase = phase;
                 minip = ip_tmp ;
             end
            % plot (outputSelectiveMapping.*conj(outputSelectiveMapping) + phase *500);
        end
        
       outputSelectiveMapping= ofdm( minip, params );
       
       paprSelectiveMapping(indexSymbol) = getPapr( outputSelectiveMapping )  ;
       phaseSelectiveMapping(indexSymbol) = minPhase;
    end
    
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     Maximum PAPR sequence and Reduction 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ( paprSymbol(indexSymbol) > maxPapr ) 
        maxSymbol = indexSymbol;
        maxPapr = paprSymbol(indexSymbol);
        maxipMod = ip ;
        if ( enScramble )
           maxoutputScramble = outputScramble ;
        end
        if ( enClipping )
            maxoutputClipped = outputClipped;
        end
        if ( enSelectiveMapping )
            maxoutputSelectiveMapping = outputSelectiveMapping;
        end
        maxoutputiFFT = outputiFFT ;
        %ipMod(maxSymbol,:)
    end
    if ( paprSymbol(indexSymbol) < minPapr ) 
        minSymbol = indexSymbol;
        minPapr = paprSymbol(indexSymbol);
        minipMod = ip ;
        minoutputiFFT = outputiFFT ;
        %ipMod(maxSymbol,:)
    end
    
    % concatenating the symbols to form the final output
    % 현재는 필요없음.
    % st = [st outputiFFT_with_CP];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     HPA model
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    HPA = Rapp( p, VSat, outputiFFT ) ;
    if ( enClipping ) 
        HPAClipped = Rapp( p, VSat, outputClipped ) ; 
    end 
    if ( enScramble ) 
        HPAScramble = Rapp( p, VSat, outputScramble ) ; 
    end 
    if ( enSelectiveMapping ) 
        HPASelectiveMapping = Rapp( p, VSat, outputSelectiveMapping ) ;
        
    end 
  
end


%% Plot the result

if ( sim.ipModPlot == 1 ) 
    figure
    hold on
    plot ( maxipMod, 'r*' )
    plot ( minipMod+4, 'b*' )
end 

if ( sim.enWavePlot == 1 ) 
    figure ('Name','transmit power ');
    hold on
    plot (  maxoutputiFFT.*conj(maxoutputiFFT) , 'r', 'DisplayName', 'Max PAPR ', 'LineWidth' ,3  )
    %plot (  minoutputiFFT.*conj(minoutputiFFT) , 'g', 'DisplayName', 'Min PAPR  ', 'LineWidth' ,2  )
    if ( enScramble )
        plot (maxoutputScramble.*conj(maxoutputScramble) , 'm' , 'DisplayName', 'Scrambler', 'LineWidth' ,3  )
    end
    if ( enClipping )
        plot (maxoutputClipped.*conj(maxoutputClipped) , 'b' , 'DisplayName', 'Clipped', 'LineWidth' ,3  )
    end
    if ( enSelectiveMapping )
        plot (maxoutputSelectiveMapping.*conj(maxoutputSelectiveMapping) , 'g', 'DisplayName', 'Selective Mapping' , 'LineWidth' ,3  )
    end
end 

if ( sim.histPlot == 1 )
    figure ('Name','PAPR with no reduction ');
    AvgPAPR = sum(paprSymbol)/length(paprSymbol)
    VarPAPR = var(paprSymbol)
    hist( paprSymbol, 20 );
    if ( enScramble == 1 ) 
        figure ('Name','PAPR with Scrambler ');
        hist( paprScramble, 20 );
        
        AvgPAPR = sum(paprScramble)/length(paprScramble)
        VarPAPR = var(paprScramble)
    end
    
    if ( enClipping )
        figure ('Name','PAPR with clipped ');
        hist( paprClipped, 20 );
        
        AvgPAPR = sum(paprClipped)/length(paprClipped)
        VarPAPR = var(paprClipped)
    end
    if ( enSelectiveMapping )
        figure ('Name','PAPR with Selective Mapping ');
        hist( paprSelectiveMapping, 20 );
        
        AvgPAPR = sum(paprSelectiveMapping)/length(paprSelectiveMapping)
        VarPAPR = var(paprSelectiveMapping)
    end
end


if ( sim.cdfPlot == 1 )
    figure 
    hold on
    [n x] = hist(paprSymbol,[2:0.5:10]);
    plot(x, log(1-cumsum(n)/nSymbol), 'r-*', 'LineWidth',3, 'DisplayName', sprintf('Original'));
   
    if ( enScramble == 1 ) 
        [n x] = hist(paprScramble,[2:0.5:10]);
        plot(x,log(1-cumsum(n)/nSymbol),'g:','LineWidth',3, 'DisplayName', sprintf('Scrambler'))
    end
    if ( enClipping )
        [n x] = hist(paprClipped,[2:0.5:10]);
        plot(x,log(1-cumsum(n)/nSymbol), '-x', 'LineWidth',3, 'DisplayName', sprintf('Clipping'))
    end
    if ( enSelectiveMapping )
        [n x] = hist(paprSelectiveMapping,[2:0.5:10]);
        plot(x,log(1-cumsum(n)/nSymbol),'m-<', 'LineWidth',3, 'DisplayName', sprintf('Selective Mapping'))
    end
end

    if ( nSymbol < 2 ) 
        figure ('Name','HPA effect ')
        hold on
        
        plot(  outputiFFT .* conj( outputiFFT ), 'DisplayName', 'Original','LineWidth', 3)
        plot( HPA .* conj( HPA ), 'g', 'DisplayName', 'HPA','LineWidth', 3)
        if ( sim.enScramble )
        plot(  real(HPAScramble-outputScramble), 'y' , 'DisplayName', 'Scrambler')
        end
        if ( sim.enSelectiveMapping )
        plot(  real(HPASelectiveMapping-outputSelectiveMapping), 'g', 'DisplayName', 'Selective Mapping' )
        end
    end  
    
    AvgPAPR = sum(paprSymbol)/length(paprSymbol);
    VarPAPR = var(paprSymbol);
    PAPR = paprSymbol;
end


function ofdmout = ofdm(ofdmin, params)
    mapperout     = NMapper( ofdmin,  params );
    pilotout      = NPilot( mapperout, params );
    ofdmout       = IFFTnAddCP( pilotout, params );
end


function outPapr = getPapr(outputiFFT)

    % computing the peak to average power ratio for each symbol
    meanSquareValue = outputiFFT*outputiFFT'/length(outputiFFT);
    peakValue = max(outputiFFT.*conj(outputiFFT));
    outPapr = peakValue/meanSquareValue; 
end


function outScramble = getScramble(inSeq)

     
    lSeq = length(inSeq);
    psuedoRan = zeros(1, lSeq );
    
    poly = ones(1,7);
    for i=1:lSeq
            poly = [ xor(poly(7), poly(4)), poly(1:6) ];
            psuedoRan(i) = poly(1);
    end
    outScramble = xor( inSeq, psuedoRan);
    
end


function ip = getInput( numOne, nBitPerSymbol) 
    ip = zeros(1, nBitPerSymbol) ;
    switch numOne
        case {-1}
            ip = rand(1,nBitPerSymbol) > 0.5;
        case {-2}
            ip(1:2:(nBitPerSymbol)) =1 ;
        case {-3}
            ip(1:4:(nBitPerSymbol)) =1 ;
            ip(2:4:(nBitPerSymbol)) =1 ;
        case {-4, -5, -6, -7 , -8, -9 ,-10, -11, -12}
            maxidx = abs(numOne)-1;
            for idx=1:maxidx
                ip(idx:maxidx*2:(nBitPerSymbol)) =1 ;
            end
        otherwise
            disp('Unknown input.')
    end
end


function Vout = Rapp( p, VSat, Vin ) 

    % power_amp0();
    %
    % Rapp's model: Vout = Vin/(1+(|vin|/Vsat)^(2p))^(1/2p)
    % where BackOff = 10log(Psat/avg(Vout^2))  
    %         ===> Psat = avg(Vout^2)*10^(10/Backoff)
    % Vsat = sqrt(Psat)
    % 
    % Each DAC output power is 40dB (100 RMS)for each antenna
    % I channel (or Q channel) has average 37dB input power to power amp., 
    % which is equal to output power of power amp
    % 
    % Therefore Vsat = sqrt(Psat) = (37dB) * 10^(10/Backoff)
    % When Backoff=10dB ==> Psat=5011.87*10=50118.7 ===> Vsat= 223.87
    % Check back
    % Average input voltage = 70.795 (sqrt(37dB))
    % Saturation_voltage (Vsat) = Average_input_voltage * 3.162 (10dB) = 223.87
    %

    %P =2 ;

    %Vout = Vin./(1+ ( abs(Vin)/VSat ).^(2*p) ).^(1/2/p) ;
    Vout = Vin./(1+ ( abs(Vin)/2).^(2*p) ).^(1/2/p) ;
end
