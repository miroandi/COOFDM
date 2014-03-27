%% Initialize 
MHz = 1e6;
mW =1e-3;
if ( sim_mode ~= 0 )
    
     [sim, params, MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD]= InitOFDM_11Sept(NFFT, 1,SampleTime );

   sim.tone = tone * params.NFFT/128;
    sim.en_disp_env =1 ;
    sim.MAXSIM= maxsim;
    % 1: Current design, 2: Ref[2] ,3:Idea 2 ,4:Idea 2 -1, 5:Idea 1 6: Ref[8] 
    sim.cfotype =cfotype; 
    sim.precomp_en = precomp_en;
    %% Simulation enviroment 
    sim.nonoise = nonoise;
    sim.nophase=1;
    sim.nolinewidth=nolinewidth;
    sim.en_AWGN = en_AWGN ;
    sim.SNR = [ 16; 16];
    sim.backtoback = b2b;
    sim.FiberLength = FiberLength  ;
    sim.mode = sim_mode; % 0: single simulation 1 : length, 2: SNR  4: bit (fixed sim) 
    sim.subband=subband;
    sim.extcon = extcon;
    laser.freqoff   =0*100 *MHz;% 1/params.NFFT  * 0.66   ; % 1* 265 *MHz;%87*MHz; %96
    
    dir_data='.';    
    params.Nbpsc = Nbpsc;    
    params.NOFDE = NOFDE;
    sim.osnrin = osnrin;    
    sim.syncpoint=syncpoint;    
    sim.txLPF_en =0 ;
  
    rxedfa.nonoise =noedfanoise;
    txedfa.nonoise =noedfanoise;
    edfa.nonoise =noedfanoise;
    params.CPratio =CPratio;
   params.MIMO_emul = 0;
   sim.en_find_cs=0;
   params.NSymbol = 50;
% fiber.Npol =params.RXstream ;   
    run('../Optisys/init_optisys.m');
end 
[sim, params, fiber,laser,lolaser,txedfa, edfa, rxedfa ]=  ...
    ReInitOFDM( logfile, sim, params, ...
    MZmod,fiber,laser, iolaser, txedfa, edfa, rxedfa, PD );

sim.stopcnt = sim.MAXSIM * params.totalbits *0.005;
 
params.NOFDE = NOFDE;
 if ( params.NOFDE ~= 0 && sim.precomp_en < 1 )
%      sim.en_OFDE =1;
 else
     sim.en_OFDE = 0;
 end

%% Simulation test set 
% 1 : Fiber length  
% 2 : OSNR  
% 4 : SNR 
% 6 : CFO 
% 7 : subband # 
laser.freqoff  =  laser.freqoff *params.SampleTime  ;
% sim.exp_cfo  = 2* laser.freqoff  * params.NFFT;

sim.showinteger =1;
%% initialization for the simuation
exp_cfo=[];
optiout =[];
dataf_t=[];
BER = zeros(size(X_coor));
MSEE = zeros(size(X_coor));
bit_err_sim=zeros(size(X_coor));
%% Main body of the simulation

[preambleout, sim.STF, sim.LTF]   = Preamble_PreComp( params, sim ) ;


zerohead =  2000;
sim.zerohead2 = zerohead;%-64;
if ( sim.precomp_en == 2 || sim.precomp_en == 3)
zerohead = zerohead/sim.subband1;
end
sim.zerohead = zerohead;
preambleout = [ zeros(size(preambleout,1), zerohead) preambleout];
for SNRsim=1:length(X_coor)
    defaultStream.State = savedState;
    totbiterror=0; totESNR =0 ; SEE = 0;  
    optiout=[];
    snr1=0;
    diff_rtx =[];
    if ( sim.mode == 2 )
        sim.osnrin =X_coor(SNRsim);
        snrin = osnr2snr(sim.osnrin, sim.oversample/params.SampleTime);
        sim.SNR = [ snrin; snrin;];
    end
    if ( sim.mode == 4 )
        sim.SNR =[X_coor(SNRsim);X_coor(SNRsim);];
    end
    if ( sim.mode == 1 || sim.mode == 5  ) 
        sim.FiberLength  = (X_coor(SNRsim))*km;        
    end 
    if ( sim.mode == 3 ) 
        txedfa.gain_dB =X_coor(SNRsim);
    end 
    if ( sim.mode == 6 ) 
        laser.freqoff  = X_coor(SNRsim) * MHz *params.SampleTime ; 
%         sim.exp_cfo  = 2*laser.freqoff * params.NFFT;
        
    end 
    if ( sim.mode == 7 ) 
        sim.nlc_coef =X_coor(SNRsim);        
    end     
    if ( sim.mode == 8 ) 
        sim.syncpoint =X_coor(SNRsim);        
%         sim.ttt = X_coor(SNRsim);        
    end 
    % Sample당 compensation할 phase 계산 
    sim.exp_cfo  = laser.freqoff * 2*pi ;     
    
    [sim.precom_CD, sim.delay, sim.phase, sim.delay_diff ] = NCalDelay_ver2(fiber, params, sim) ;   
    [packetlen, optchannelout] = run_Opt( sim.en_optisyschannel,Document, Canvas, dir_in, dir_data, params, sim, edfa,txedfa );
    
    if ( sim.en_optisyschannel == 1 && sim.en_read_ADS == 0 )
        continue ;	    
    end

    for numsim=1:sim.MAXSIM
        
        dataf = GenStim(params.totalbits, sim, 'prbs15.txt', dataf_t, ...
                        mod((numsim-1)*params.totalbits, 2^15-1) ) ; 
        if ( sim.en_read_ADS == 1 )
            noisyreceivein = optchannelout(:,(numsim-1)*packetlen+1:numsim*packetlen);
        else
            %=================  Transmitter =================        
            ofdmout=  TxMain( dataf, preambleout, sim, params,  ...
                              txedfa, edfa, laser, fiber,MZmod );
                          
            ofdmout = NSamplingFreqOffset( sim.txfreqoff, ...
                                           sim.txtimeoff, ofdmout );
           
            if ( sim.en_gen_ADS == 1 )
                optiout       = [ optiout ofdmout zeros(params.Nstream, 1000)]; 
            else
                ofdmout = ofdmout * sim.txgain ;
                %============ Electric signal to optical ===============
                if ( params.MIMO_emul == 1 )
                    MIMO_ofdmout(1,:) =[ ofdmout(1,:) zeros(1, sim.zeropad1+sim.zeropad2+sim.zeropad3) ];
                     MIMO_ofdmout(2,:) =[ zeros(1, sim.zeropad3)  ofdmout(1,:) zeros(1, sim.zeropad1+sim.zeropad2) ];
                     ofdmout = MIMO_ofdmout;
                end
                [ovoptofdmout, txphase_noise] =  ...
                    elec2opt1( ofdmout, laser,  MZmod, txedfa, sim,params );


                ovoptofdmout = NLowPassFilter1( ovoptofdmout, sim.txfilter, sim.txLPF_en1 );
                %============ Channel ==================================
                noisychannelout =  ...
                    channel( ovoptofdmout , fiber, edfa, sim, params ); 
                %============ Optical signal to electrial ==============
                noisyreceivein = NCarrierFreqOffset( noisychannelout, laser.freqoff/sim.oversample );
                
                noisyreceivein = NLowPassFilter1( noisyreceivein, sim.rxfilter, sim.rxLPF_en );
                [noisyreceivein, rxphase_noise] =   ...
                    opt2elec1( noisyreceivein, lolaser,  PD, rxedfa, sim,params);               
                
%                 noisyreceivein = noisyreceivein*sqrt(2);
                
            end
        end  %if ( sim.en_optisyschannel == 1 )
        if ( sim.en_gen_ADS == 0 )
            %===================== OFDM Receiver ===================================
            

            [sim.Launchpower, LP_dB]=   GetLaunchPwr(laser, sim, MZmod, txedfa );
             

            noisyreceivein1 = noisyreceivein(:,sim.zerohead2 +1:size(noisyreceivein,2)) ;
            [demapperout, fftout, H_modified, cfo_phase, commonphase, snr] = ...
                RxMain( noisyreceivein1, params, sim, fiber  );

            %================= Analysis BER and PAPR ================= 
            [frame, idealout,EVM_dB_sc, EVM_dB_sym ] = ...
              FrameAnalysis( dataf,demapperout,fftout, cfo_phase, params, sim, snr);
            totbiterror = totbiterror  + frame.Nbiterr ;
            totESNR = totESNR + frame.ESNR ;
            SEE = SEE + frame.cfo_err;  
            bit_err_sim(SNRsim, numsim) =sum(frame.Nbiterr);% totbiterror/( numsim *params.totalbits);
            if ( params.Nstream == 1 ||  params.MIMO_emul == 1)
                diff_rtx =[ diff_rtx   frame.diff_rtx ];
            else
                diff_rtx =[ diff_rtx ;  frame.diff_rtx ];
            end
            
            if ( mod(numsim,10) ==0 || numsim == sim.MAXSIM )    
                str = ['the number of simulations :', num2str( numsim),  ...
                 ' BER:',  num2str(totbiterror/( numsim *params.totalbits)), ...
                ' MSEE:',  num2str(SEE/numsim), ...
                ' CurSim: ', num2str(X_coor(SNRsim)) ] ;   
                disp2(logfile, str);
            end   
%             if ( frame.Nbiterr > 1000 )
%                 disp('tt');
%             end
        end
        if ( next_sim( sim, sum(totbiterror), numsim,maxsim, bit_err_sim ,SNRsim) == 1 )
            break;
        end
    end
    
   if ( sim.en_gen_ADS )
        gennerate_ADS( sim.en_gen_ADS, optiout, dataf_t, dir_in, params, sim, edfa );
        continue ;	 
   end
   
   %% Report 
    BER(SNRsim) = max(1e-9, sum(totbiterror)/( numsim * params.totalbits));
    Q(SNRsim) = 10*log10(2* totESNR / numsim );
    MSEE(SNRsim) =  SEE / numsim ;
    str = ['FiberLength :', num2str( sim.FiberLength/km ), 'km, sim.precom_CD  ', ...
    num2str( sim.precom_CD ), ...
        ' BER:',  num2str(BER(SNRsim)), ...
        ' MSEE:',  num2str(MSEE(SNRsim)), ...
        ' Q:',  num2str(Q(SNRsim)), ...
        ' CurSim: ', num2str(X_coor(SNRsim)) ] ;  
    disp2( logfile, str);

%     disp2(logfile,datestr(now,'HH:MM /mm/dd/yy'));
mean_power_s =sum((mean(abs(noisychannelout) .^2)));
mean_power_s1 =sum((mean(abs(ovoptofdmout) .^2)));
MSNR(SNRsim)= ...
10*log10(mean_power_s1/(mean_power_s-mean_power_s1));

% createfigure(commonphase,H_modified,  params, frame,sim, '' )
%     write_singlefile( sdirdlm, sim, params, BER(SNRsim), Q(SNRsim), ...
%         bit_err_sim(SNRsim,:), totbiterror );

end


% [snr, OSNR] = get_snrt(noisyreceivein(1,:), 1/params.SampleTime)
% mean_power=sum((mean(((abs(ovoptofdmout) .^2))/1e-3, 2)));
% str3 =[ 'mean power ', num2str(10*log10(mean_power)),' dBm'];
% disp(str3);
%% Simulation for MMSE vs. Carrier frequency offset 
if ( sim.noplot ~= 1 && SNRsim ~= 1 ) 
%    plot_ber_cfo( sim, params, X_coor, BER, MSEE , edfa, laser );
   plot_ber_sb( sim, params,   X_coor , BER, Q , edfa, laser );
%    write_outfile( dirdlm, sim, params, X_coor, BER, Q );
end

%%
if ( sim.en_optisyschannel == 1 )
   optsys.Quit;
end

% createfigure(commonphase,H_modified,  params, frame,sim, '' )
