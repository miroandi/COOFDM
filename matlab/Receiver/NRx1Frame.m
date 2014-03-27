function maxoffset = NRx1Frame(offset, ioffsetmax,  maxidx, numsim, dataf_t, params, sim, handles)
    [preambleout, sim.STF, sim.LTF]   = Preamble_PreComp( params, sim ) ;
    %% Initial 
    max_ESNR =0 ;
    min_Nbiterr = 1e9;
    idx=0;
    rxpacketlen = params.packetlen  + sim.zeropad + sim.zeropad1 + sim.zeropad2 + sim.zeropad3  ;
    
    %%
     
    cfo_est=0;
    if ( handles.Homodyne == 0 )         
        cfo_est_inv = max(1,(offset -(sim.zeropad1-100)*sim.stepidx )):(offset -100*sim.stepidx );    
        [ cfo_est, mean_dc, sim.dc_freq] = cfo_calc( complex(handles.couti(cfo_est_inv),handles.coutq(cfo_est_inv)) );
        sim.exp_cfo = cfo_est *2*pi*1e3/10e6; % MHz -> Normalized 
        disp( ['Est CFO : ',num2str(cfo_est),'MHz']);
    else 
        cfo_est =0;
        sim.exp_cfo =0;
        if ( params.MIMO_emul == 1  &&  sim.FiberLength ~= 0 )
            sim.exp_cfo=  100/(10e9/2/pi/1e6);% 0.0628;
        end
    end
    
    
    for sync = sim.syncpointlist
    for ISFASize = sim.ISFASizelist
    for ISFASize1 = sim.ISFASize1list
        sim.ISFASize = ISFASize;
        sim.ISFASize1 = ISFASize1;
        sim.syncpoint =sync ; 
        for Launchpower_dB = sim.Launchpower_dB + sim.Launchpowerlist % [0:0.2:1 ]  
        for iqdelay  = 0 
%             sim.nlcoef_cross =coef_b ;
%             sim.ofde = ofde ;
            sim.Launchpower =    1e-3 *  10^(Launchpower_dB/10);
%             iqdelay = 0 ; % [ -70:2:-50]  % 1 %0:1:2 
            iqdelay1  =0;
        for ioffset = 0:ioffsetmax
            idxlist = offset+ioffset+1:sim.stepidx:(maxidx -3) ;
            idxlist1 = idxlist   + iqdelay ;
        
            if ( handles.params.RXstream == 2)
%                 x=1:size(handles.couti(:, idxlist),2);
%                 couti(1,:) = interp1(x,handles.couti(1, idxlist),x,'spline');
%                 coutq(1,:) = interp1(x,handles.coutq(1, idxlist  ),x  + 0.01 * iqdelay1,'spline');                  
%                 couti(2,:) = interp1(x,handles.couti(2, idxlist),x   ,'spline');
%                 coutq(2,:) = interp1(x,handles.coutq(2, idxlist  ),x  + 0.01 * iqdelay ,'spline'); 
%                 handles.optchannelout =[ complex( couti, coutq); ];
             
                 handles.optchannelout = ...
                 complex( handles.couti(:, idxlist), handles.coutq(:, idxlist)  );            
            else
                x=1:size(handles.couti(:, idxlist),2);
                couti = interp1(x,handles.couti(:, idxlist),x,'spline');
                coutq = interp1(x,handles.coutq(:, idxlist),x + 0.01 * iqdelay,'spline');  
%                 couti =  handles.couti(:, idxlist) ;
%                 coutq =  handles.coutq(:, idxlist) ;  
                handles.optchannelout = complex( couti , coutq );
            end
            handles.optchannelout = [handles.optchannelout zeros(size(handles.optchannelout,1), 300)];
            mean_dc = 0.0016-0.0000034537+(-0.0014+0.00002784)*1j;            
            handles.optchannelout = handles.optchannelout -mean_dc;
              
            handles.optchannelout = NSamplingFreqOffset( 0, 0 , handles.optchannelout);
            dataf = GenStim(params.totalbits, sim, 'prbs15.txt', dataf_t,0 ) ;  
            noisyreceivein = handles.optchannelout(:, (idx+(numsim-1)* rxpacketlen+1: idx+numsim * (rxpacketlen +100))+ sim.fsync_point );   
            [noisyreceivein, iqamp] = IQimbal(sim.enIQbal, noisyreceivein)  ;
            %================= OFDM receiver         ================= 
            [demapperout, fftout, H_modified, cfo_phase, commonphase,snr, fsync_point] =...
                RxMain( noisyreceivein,  params, sim, handles.fiber  );

            %================= Analysis BER and PAPR ================= 
            [frame, idealout,EVM_dB_sc, EVM_dB_sym ]= ...
                FrameAnalysis( dataf,demapperout, fftout, cfo_phase, params, sim, snr  );
%             if (      max_ESNR < frame.ESNR ) 
                if ( ( min_Nbiterr > sum(frame.Nbiterr) ) || ...
                    ( sum(frame.Nbiterr) == min_Nbiterr &&  max_ESNR < frame.ESNR ) )
           
                maxoffset.frame = frame ;
                max_ESNR = frame.ESNR;
                maxoffset.max_offset = ioffset;
                min_Nbiterr =  sum(frame.Nbiterr);
                maxoffset.idealout = idealout;
                maxoffset.EVM_dB_sc = EVM_dB_sc;
                maxoffset.EVM_dB_sym = EVM_dB_sym;
                maxoffset.H = H_modified;
                maxoffset.fftout = fftout;
                maxoffset.commonphase = commonphase;
                maxoffset.noisyreceivein = noisyreceivein;
                maxoffset.iqoffset = 0;
                maxoffset.ISFASize = ISFASize;
                maxoffset.ISFASize1 = ISFASize1;  
                maxoffset.syncpoint = sim.syncpoint;  
                maxoffset.frame.syncpoint = sim.syncpoint; 
                maxoffset.fsync_point = fsync_point ;
                maxoffset.Launchpower=  sim.Launchpower ;
                maxoffset.iqdelay = iqdelay ;
                maxoffset.iqdelay1 = iqdelay1 ;
                maxoffset.ofde =  iqamp;%sim.ofde ;
            end
            disp2(handles.logfile, ['Q: ',num2str(10*log10(2*frame.ESNR)), ' Error ', num2str(frame.Nbiterr) ]);
        end
        end
    end
    end
    end
    end

%% Display for debugging 
if ( sim.CFOcomp_en == 1 )
    disp(['Est CFO : ',num2str(maxoffset.frame.cfo_phase*10e9/2/pi/1e6),'MHz, Exp CFO : ',num2str(cfo_est), ' MHz' ]);
    disp2( [ 'CFO', num2str(sim.cfotype), '.txt'], ...
        [num2str(maxoffset.frame.cfo_phase*10e9/2/pi/1e6),'  ', ...
        num2str(cfo_est), ' ', ...        
        sim.wavelength, ' ',...
        datestr(now,' ss MM ') ]);
end
maxoffset.expcfo = cfo_est;

% disp(['------ Delay ', num2str(maxoffset.iqdelay)]);
if ( size(sim.syncpointlist,2 ) ~= 1 )
  disp2('ISFASize.txt', ['syncpoint: ',num2str(maxoffset.syncpoint)]); 
end     
%     disp(  ['IQ delay: ',num2str(maxoffset.iqdelay),'  ',num2str(maxoffset.iqdelay1)]);
 disp(  ['LaunchPowr: ',num2str(10*log10(maxoffset.Launchpower/1e-3))]);   
%     disp(  ['ofde: ',num2str( maxoffset.ofde)]);
disp(  ['IQ imbalance: ',num2str( iqamp)]);
if ( size(sim.ISFASizelist,2 ) ~= 1 || size(sim.ISFASize1list,2 ) ~= 1 )
    disp2('ISFASize.txt', ['Size Size1: ',num2str(maxoffset.ISFASize), ...
        ' ',num2str(maxoffset.ISFASize1) ]);
end
