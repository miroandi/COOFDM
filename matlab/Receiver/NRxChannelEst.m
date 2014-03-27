function [H, channel_out, LTF_t, LTF2_t ] = ...
            NRxChannelEst ( channel_in1, params, sim, iqamp)

    % Channel estimation by zero forcing
    % but effect of noise is big in imaginary/(sometims real) part of channel
    % matrix. 
    % NOTE: I guess noise considered method is needed other than zero forcing, 
    % e.g. MMSE.
    LTF2_t=0;LTF_t=0;
    channel_in = channel_in1( :, 1:size(channel_in1,2));
    j = sqrt(-1);
    [d1, d2] = size (channel_in);

    STFidx=0;
    cfo_phase = 0;
    channel_scomp = channel_in;
    
    syncpoint = sim.syncpoint * params.RxOVERSAMPLE ;
    RXSymbolidx = (( params.IdxDataSymbol): params.NSample); 

    %% IQ balance
%     sim.enIQbal =0;
%     if ( sim.enIQbal ~= 0 )
%     if ( d1 == 1 )    
%         iq=channel_in(1,  STFidx+1:params.SampleperSymbol*(params.NSymbol+params.NLTF) + STFidx);
%         iqamp =  sqrt( mean(real(iq).^2)/ mean(imag(iq).^2))
%         power_mean = mean(abs(iq).^2);
%         
%         channel_scomp = complex( real(channel_scomp), imag(channel_scomp) * iqamp);
%         channel_in = complex( real(channel_in), imag(channel_in) * iqamp);
%     else
%     
%         iq=channel_in(1,  STFidx+1:params.SampleperSymbol*(params.NSymbol+params.NLTF) + STFidx);
%         iqamp1 =  sqrt( mean(real(iq).^2)/ mean(imag(iq).^2)) 
%         iq1=channel_in(2,  STFidx+1:params.SampleperSymbol*(params.NSymbol+params.NLTF) + STFidx);
%         iqamp2 =  sqrt( mean(real(iq1).^2)/ mean(imag(iq1).^2)) 
%         polamp=1;%sqrt( mean(imag(iq).^2)/ mean(imag(iq1).^2));
%         channel_scomp(1,:) = complex( real(channel_scomp(1,:)), imag(channel_scomp(1,:)) /  0.9061);
%         channel_scomp(2,:) = complex( real(channel_scomp(2,:)), imag(channel_scomp(2,:)) /  1.0838);
%         channel_in(1,:) = complex( real(channel_in(1,:)), imag(channel_in(1,:)) /  0.9061);
%         channel_in(2,:) = polamp * complex( real(channel_in(2,:)), imag(channel_in(2,:)) / 1.0838);
%     end
%     end
    %% Carrier frequency offset estimation using Long preamble 
    % Carrier frequency response
    if ( sim.enCFOcomp ~= 0 )

        firstLTF= channel_scomp( :, params.RXfirstLTFidx -syncpoint   );
        secondLTF=channel_scomp( :, params.RXsecondLTFidx -syncpoint );    
        if ( sim.cfotype == 7 )
            firstLTF_1half = firstLTF( :, (1:size(firstLTF, 2)/2));
            firstLTF_2half = firstLTF( :, (size(firstLTF, 2)/2 + 1:size(firstLTF, 2)));                   
            LTFoffset = (firstLTF_2half) .*  conj(firstLTF_1half)  ;
            LTFoffset = Change_fixed_bit(LTFoffset, sim.MulOutbit);
            repsize = length(LTFoffset);
            cfo_phase2 =  angle(sum( LTFoffset(1,:)))/repsize;     
            cfo_phase = cfo_phase + Change_fixed_bit_lim( cfo_phase2, sim.ATANbit,pi);
        else   
            LTFoffset = (secondLTF) .*  conj(firstLTF)  ;
            LTFoffset = Change_fixed_bit(LTFoffset, sim.MulOutbit);
            repsize = (length(LTFoffset)*( 1 + params.CPratio));
            cfo_phase2 =  angle(sum( LTFoffset(1,:)))/repsize;     
            cfo_phase = cfo_phase + Change_fixed_bit_lim( cfo_phase2, sim.ATANbit,pi);
        end 
%         2(['Normalized CFO Phase', num2str(cfo_phase), ' CFO freq ', num2str(cfo_phase*10e9/2/pi/1e6),  ' MHz' ]);
    end 

 
    channel_comp = channel_in(:,STFidx+1:d2) .* ...
        ( ones(d1,1) *  ( exp( -j * cfo_phase * (1:d2-STFidx))));
%     channel_comp =  Change_fixed_bit_lim( channel_comp, sim.ADCbit , 1);
    channel_comp = Change_fixed_bit( channel_comp, sim.MulOutbit  );
   
    %% Channel estimation averaging
    if ( params.NLTF ~= 0 )            
        if (  sim.cfotype == 7 && params.Nstream == 2)
            LTFoffset = 0;%params.NFFT * (params.CPratio +1 );
        else
            LTFoffset =0 ;
        end
        firstLTF  = channel_comp( :, params.RXfirstLTFidx  -syncpoint + LTFoffset );
        secondLTF = channel_comp( :, params.RXsecondLTFidx -syncpoint + LTFoffset );          
        thirdLTF  = channel_comp( :, params.RXthirdLTFidx  -syncpoint + LTFoffset );
        fourthLTF = channel_comp( :, params.RXfourthLTFidx -syncpoint + LTFoffset );
        if (params.NLTF == 1)
            avg_firstLTF  =  (firstLTF );
            avg_secondLTF =  (secondLTF);
        end
        if (params.NLTF == 2)
            avg_firstLTF  =  (firstLTF + secondLTF )/2;
            avg_secondLTF =  (thirdLTF + fourthLTF )/2;        
        end
    end
    %% Channel estimation using Long preamble 
    if ( params.NLTF == 0 )  
        H=[];
        channel_out=[];

    elseif ( sim.cetype == 7 )
        %% EEO type 
        if ( d1 == 1 )
            LTF_t = avg_firstLTF ;
            LTF = (fft( LTF_t, [],2) );
            % Even channel 
            H =( params.LTF ) ./ (LTF(:, 1:params.NFFT ))  ; 
            LTF_t = avg_secondLTF ;
            LTF = (fft( LTF_t, [],2) );
            % Odd channel 
            H(2:2:params.NFFT) =( params.LTF(2:2:params.NFFT)) ./ (LTF(:, 2:2:params.NFFT ))  ; 
            H = H *sqrt(2);             
        else             
            LTF_t = avg_firstLTF ;
            LTF2_t = avg_secondLTF ;
            H = CalcH2_EEO( LTF_t, LTF2_t, sim, params);
        end
        channel_out = channel_comp(:, RXSymbolidx -syncpoint);

    else
        %% AA type 
        if ( params.Nstream == 1 )
            LTF_t = avg_firstLTF;   
            LTF = (fft( LTF_t, [],2) );
            LTF = Change_fixed_bit( LTF, sim.FFTOutbit ); 
        else
            LTF_t = (avg_firstLTF*params.LTFtype(1,1) + ...
                (avg_secondLTF )*params.LTFtype(1,2) )/(  sum(abs(params.LTFtype(1,:))));    
            LTF2_t = ((avg_firstLTF )*params.LTFtype(2,1) + ...
            (avg_secondLTF)*params.LTFtype(2,2) )/( sum(abs(params.LTFtype(2,:))));  
        end 
        
        if ( d1 == 1 )
            H =( params.LTF) ./ ( LTF(:, params.RXFFTidx))  ; 
        else  %% 2     
           H = zeros( 2, params.Nstream, params.NFFT);
            if ( params.Nstream == 1 )
                H = CalcH1( LTF, sim, params);
            else
                H = CalcH2( LTF_t, LTF2_t, sim, params);            
            end
        end
        H = Change_fixed_bit( H * params.preamblefactor, sim.DCTOutbit );           
        channel_out = channel_comp(:, RXSymbolidx -syncpoint);
    end
    
    
   
end


%% Multi Input Channel estimation
function H = CalcH1( LTF, sim, params)
     Response(1,:,:) = LTF(:, 1:params.NFFT ) .* [ params.LTF; params.LTF]  ;           
                
    for ii=1:(length(params.LTFindexE))
    idx=params.LTFindexE(ii);
    H(:,1, idx) = ctranspose(Response(1,:,idx)) ...
          / ( Response(1,:,idx) *ctranspose(Response(1, :,idx)));                         
    end
end




function H = CalcH2_1( LTF_t, LTF2_t, sim, params)
    LTF = (fft( LTF_t, [],2) ); 
    LTF = Change_fixed_bit( LTF, sim.FFTOutbit ); 
    LTF2 = (fft( LTF2_t, [],2) );
    LTF2 = Change_fixed_bit( LTF2, sim.FFTOutbit ); 

    RX(1,:,:) = [LTF(1, 1:params.NFFT ); LTF2(1, 1:params.NFFT ); ]  ;
    RX(2,:,:) = [LTF(2, 1:params.NFFT ); LTF2(2, 1:params.NFFT ); ]  ;
    TX(1,:,:) = [params.LTFtype(1,1) * params.LTF ; params.LTFtype(1,2) * params.LTF] ;
    TX(2,:,:) = [params.LTFtype(2,1) * params.LTF ; params.LTFtype(2,2) * params.LTF] ;
    H = zeros( 2, params.Nstream, params.NFFT);
    
    for ii=params.LTFindexE
%         H(:,:,params.LTFindexE(ii)) =(TX(:,:,params.LTFindexE(ii)) )/RX(:,:,params.LTFindexE(ii)) ;
        H(:,:, ii ) =  transpose( TX(:,:,ii) / RX(:,:,ii) );
    end
     
end

%% EEO type Channel estimation

function H = CalcH2_EEO( LTF_t, LTF2_t, sim, params)
    LTF = (fft( LTF_t, [],2) );
    LTF = Change_fixed_bit( LTF, sim.FFTOutbit ); 
    LTF2 = (fft( LTF2_t, [],2) );
    LTF2 = Change_fixed_bit( LTF2, sim.FFTOutbit ); 

    %% Even 
    LTFzero = zeros(size(params.LTF));
    Response(1,:,:) = LTF2(:, 1:params.NFFT )  .* [ params.LTF; params.LTF]  ;
    Response(2,:,:) = LTF(:, 1:params.NFFT )  .* [ params.LTF; params.LTF]   ;
    H = zeros( 2, params.Nstream, params.NFFT);
    if ( params.Nstream == 1 )
        for ii=1:(length(params.LTFindexE))
            idx=params.LTFindexE(ii);
            H(:,1, idx) = ctranspose(Response(1,:,idx)) ...
                      / ( Response(1,:,idx) *ctranspose(Response(1,:,idx)));
        end
    else                
        for ii=1:(length(params.LTFindexE))
            H(:,:,params.LTFindexE(ii)) = inv(Response(:,:,params.LTFindexE(ii)));
        end
    end 
    
    %% Odd channel
    Response(1,:,:) = LTF(:, 1:params.NFFT ).* [ params.LTF; params.LTF]   ;
    Response(2,:,:) = LTF2(:, 1:params.NFFT )  .* [ params.LTF; params.LTF]  ;
     
    if ( params.Nstream == 1 )
        for ii=1:(length(params.LTFindexE))
            idx=params.LTFindexE(ii);
            if ( mod(idx,2) == 0 )
            H(:,1, idx) = ctranspose(Response(1,:,idx)) ...
                      / ( Response(1,:,idx) *ctranspose(Response(1,:,idx)));
            end
        end
    else                
        for ii=1:(length(params.LTFindexE))
            idx=params.LTFindexE(ii);
            if ( mod(idx,2) == 0 )
            H(:,:,params.LTFindexE(ii)) = inv(Response(:,:,params.LTFindexE(ii)));
            end
        end
    end
    
    H =  H *sqrt(2); 
end
