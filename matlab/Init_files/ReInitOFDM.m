function [sim_new, params_new,fiber_new, laser_new,lolaser_new,txedfa_new, edfa_new, rxedfa_new ]=  ReInitOFDM( logfile, sim, params, MZmod,fiber,laser, lolaser, txedfa, edfa, rxedfa, PD )

sim_new=sim;
params_new=params;
laser_new=laser;
lolaser_new=lolaser;
txedfa_new= txedfa;
rxedfa_new= rxedfa;
edfa_new=  edfa;
fiber_new= fiber;
%%  Define constants, unit 
fs = 10^-15 ;
ps = 10^-12;
nm = 10^-9 ;
THz = 10 ^ 12 ;
MHz = 1e6;
GHz = 1e9;
kHz = 1e3;
km = 10^3;
mW = 1e-3;
um = 1e-6;
W = 1;
mV =1e-3;
ppm = 1e-6;
c = 2.99e8;  % Speed of light 
h =6.6e-34;  % Plank constant, J.s
Z0 = 377 ;                                       % ohm

j=sqrt(-1);
%%

if ( sim_new.backtoback ==1 ) 
    sim_new.nlcompen = 0 ; 
    sim_new.nlpostcompen = 0;
end
if ( sim_new.backtoback ==1 )
    sim_new.FiberLength = 0 *km;
end
if ( sim_new.nolinewidth ==1 )
    laser_new.linewidth =  0 *kHz; 
    lolaser_new.linewidth =  0 *kHz; 
else
%     sim_new.enCPEcomp =1;
end

if ( sim_new.nonoise ==1 )    
    txedfa_new.nonoise =1;
    rxedfa_new.nonoise =1;
    edfa_new.nonoise = 1;
end


if (  sim_new.subband == 0 )    sim_new.precom_CD =0;   sim_new.precomp_en = 0;  end
if ( sim_new.precomp_en == 0 )    sim_new.precom_CD =0;   sim_new.subband = 0;  end
if ( fiber.Npol == 1)     fiber_new.DGD =0 ; end 

if ( sim.offset_QAM == 1 )
    params_new.CPratio =0 ;
end 

% sim_new.syncpoint = params_new.CPratio*params_new.NFFT/2;



%%
GHz=1e9;

% params_new.SampleTime = Ts1*(params_new.Nbpsc )/2 * ( 1 +1/8)/( 1 +params_new.CPratio ) ;
% params_new.SampleTime =1/10/GHz;
params_new.SampleperSymbol =  params_new.OVERSAMPLE * params_new.NFFT * ( 1 +params_new.CPratio);
params_new.RxSampleperSymbol =  params_new.RxOVERSAMPLE * params_new.NFFT * ( 1 +params_new.CPratio);
SubcarrierIndex2 = sort(-params_new.SubcarrierIndex1); 
params_new.SubcarrierIndex = [params_new.SubcarrierIndex1+1 SubcarrierIndex2+params_new.NFFT+1  ];

PilotIndex2 = sort(-params_new.PilotIndex1); 
params_new.PilotIndex= [ params_new.PilotIndex1+1 PilotIndex2+params_new.NFFT+1 ];

% 
% params_new.SubcarrierIndex = [SubcarrierIndex1+1   ];
% params_new.PilotIndex= [ PilotIndex1+1  ];

%% STF, LTF length
params_new.one_stf =0 ;
params_new.repSTF = 9;
params_new.rep2STF = 16;
params_new.lenSTF =params_new.NFFT*(1+params_new.CPratio);

% CFO Algorithm
[sim_new, params_new] = InitCFO( sim_new, params_new );
   
params_new.LTFindex = [params_new.SubcarrierIndex params_new.PilotIndex];
params_new.LTF = zeros(1, params.NFFT);
params_new.LTF(params_new.LTFindex) =  params.LTF(params_new.LTFindex);
params_new.LTFindexE = [params_new.SubcarrierIndex params_new.PilotIndex]; % Extende LTF index for ISFA 
if (params.ignore_edge_sb == 1 )    
    params_new.AddEdgeScIndx= [(params_new.AddEdgeSc +1)  -params_new.AddEdgeSc+params_new.NFFT+1  ];
    params_new.LTF( params_new.AddEdgeScIndx) =  params.LTF( params_new.AddEdgeScIndx);
    params_new.LTFindexE =  [params_new.SubcarrierIndex params_new.PilotIndex params_new.AddEdgeScIndx];
end
    

params_new.LTF(params_new.PilotIndex)=params_new.Pilot;
NumCP= floor(params_new.NFFT/2*params_new.OVERSAMPLE*params_new.CPratio+0.5)*2; 

NFFTSample = params_new.NFFT*params_new.OVERSAMPLE;
CPIndex2 = 2*params_new.CPratio;  % length(params_new.LTFseq)*params_new.CPratio ;
if ( sim_new.precomp_en == 2 || sim_new.precomp_en == 3)
    
    params_new.CPIndex = [1+(params_new.NFFT*params_new.OVERSAMPLE-NumCP)/sim.subband1:params_new.NFFT*params_new.OVERSAMPLE/sim.subband1]; 
    params_new.TXLTFCPIndex = [1+(NFFTSample-NFFTSample*params_new.CPratio)/sim.subband1:NFFTSample/sim.subband1];
    params_new.CPshift = 0 * -params_new.OVERSAMPLE * params_new.NFFT * (  params_new.CPratio)/2/sim.subband1;
else
    params_new.CPIndex = [params_new.NFFT*params_new.OVERSAMPLE-NumCP+1:params_new.NFFT*params_new.OVERSAMPLE]; 
    params_new.TXLTFCPIndex = [(NFFTSample-NFFTSample*params_new.CPratio+1) :NFFTSample ];
    if ( params_new.CPratio > 1 )
    params_new.TXLTFCPIndex = [(NFFTSample-NFFTSample*params_new.CPratio/2+1) : NFFTSample  (NFFTSample-NFFTSample*params_new.CPratio/2+1) : NFFTSample ];
    end
     params_new.CPIndex =  params_new.TXLTFCPIndex;
     params_new.CPshift = 0 * -params_new.OVERSAMPLE * params_new.NFFT * (  params_new.CPratio)/2;
end 
params_new.TXSTFIndex = [];%
for nstf=1:params_new.NSTF*params_new.NFFT/16 
    params_new.TXSTFIndex = [params_new.TXSTFIndex 1:params_new.OVERSAMPLE*16]  ;
end
params_new.RxSTFidx= params_new.NFFT*params_new.RxOVERSAMPLE*params_new.NSTF;
params_new.Nsd     =  length(params_new.SubcarrierIndex); % Number of data subcarriers
if ( params_new.en_bitalloc == 0 )
    params_new.Nbpsc_sc = params_new.Nbpsc * ones(1, params_new.Nsd);
end

params_new.Ncbps = sum(params_new.Nbpsc_sc); %params_new.Nsd * params_new.Nbpsc ;        % Number of data bits per symbol
params_new.UnusedSubcarrierIndex=[];
for ii=1:(params_new.RxOVERSAMPLE * params_new.NFFT ) 
    if ( isempty( find ( ii == params_new.LTFindex, 1)))
        params_new.UnusedSubcarrierIndex=[params_new.UnusedSubcarrierIndex ii];
    end
end 

%%
% params_new.NSample = (  ( 1 + params_new.CPratio) *  ...
%      (params_new.NLTF*params_new.Nstream   +params_new.NSymbol))*NFFTSample ;
% params_new.IdxDataSymbol = (params_new.NFFT*params_new.RxOVERSAMPLE  * (1+ params.CPratio) * ...
%                    (params_new.Nstream * params_new.NLTF + params_new.MIMO_emul  ) +1);
% if ( sim_new.cfotype == 7 )
%     params_new.NSample = (  ( 1 + params_new.CPratio) *  ...
%      ( 1 + params_new.NLTF*params_new.Nstream   +params_new.NSymbol))*NFFTSample ;
%      params_new.IdxDataSymbol = (params_new.NFFT*params_new.RxOVERSAMPLE  * (1+ params.CPratio) * ...
%                    (params_new.Nstream * params_new.NLTF +1 ) +1);
% end

RXNFFTSample = params_new.NFFT*params_new.RxOVERSAMPLE ;
RXNSymbolSample = RXNFFTSample * ( 1 + params_new.CPratio) ;
params_new.NSample = RXNSymbolSample * (params_new.NLTF*params_new.Nstream  +params_new.NSymbol) ;
params_new.IdxDataSymbol = RXNSymbolSample * ...
                   (params_new.Nstream * params_new.NLTF + params_new.MIMO_emul  ) +1 ;
if ( sim_new.cfotype == 7 && params_new.Nstream == 1 )
    params_new.NSample = params_new.NSample + RXNSymbolSample * params_new.NLTF;
    params_new.IdxDataSymbol = params_new.IdxDataSymbol + RXNSymbolSample * params_new.NLTF;
end



LTFidx = RXNFFTSample*params_new.CPratio +(1: RXNFFTSample);
% params_new.packetlen
% =params_new.NSample+params_new.NSTF*params_new.lenSTF+max(sim.delay)+100+1000;
params_new.packetlen =params_new.NSample+  2 * params.MIMO_emul *RXNFFTSample* (1+ params.CPratio) + ...
    (params_new.NSTF+params.MIMO_emul)*params_new.lenSTF+sim.zeropad; %+2000;
params_new.RXfirstLTFidx  = LTFidx + RXNFFTSample * (1+ params_new.CPratio) * 0 ;
params_new.RXsecondLTFidx = LTFidx + RXNFFTSample * (1+ params_new.CPratio) * 1 ;
params_new.RXthirdLTFidx  = LTFidx + RXNFFTSample * (1+ params_new.CPratio) * 2 ;
params_new.RXfourthLTFidx = LTFidx + RXNFFTSample * (1+ params_new.CPratio) * 3 ;
params_new.RXFFTidx = [ 1:params_new.NFFT/2, RXNFFTSample-params_new.NFFT/2+ 1:RXNFFTSample];
%% Simulation
sim_new.SNR = [ osnr2snr(sim.osnrin, sim.oversample/params_new.SampleTime); osnr2snr(sim.osnrin, sim.oversample/params_new.SampleTime)];
totalbits = params_new.Ncbps * params_new.NSymbol*params_new.Nstream;
validsymbolrate = params_new.NSymbol/(params_new.NSymbol+params_new.NSTF+params_new.NLTF*params_new.Nstream+2);
normdatarate = params_new.Ncbps  *params_new.Nstream/(params_new.SampleTime * params_new.SampleperSymbol );
datarate =normdatarate*validsymbolrate;
sim_new.exp_cfo=laser.freqoff*2*pi *params_new.SampleTime;
params_new.totalbits =totalbits;
% 
% disp2( logfile,['Expected laser freq. offset ', num2str(laser.freqoff*2*pi),' rad/Sample']);
% if (  laser.freqoff * 16 > 0.5 )
%     disp2( logfile,['Frequency estimation may fail.. out of bound']);
% end
% if (  laser.freqoff * params_new.NFFT > 0.5 )
%     disp2( logfile,['Frequency estimation may fail.. out of bound']);
% end
%% Fixed simulation
if ( sim.fixed_sim ==1 )
%     sim_new.ADCbit = 8;
%     sim_new.DACbit = 8;
%     
%     sim_new.MulOutbit = 10;
%     sim_new.ATANINbit = 8;
%     sim_new.ATANbit = 11;
% 
%     sim_new.FFTOutbit = fftoutbit;
%     sim_new.DCTOutbit = dctbit ;
%     sim_new.ATAN1bit = atan1bit ;
%     sim_new.ATAN2bit =atan2bit ;
else
    sim_new.ADCbit = 0;
    sim_new.DACbit = 0;
    sim_new.MulOutbit = 0;
    sim_new.ATANINbit = 0;
    sim_new.ATANbit = 0;
    sim_new.FFTOutbit = 0;
    sim_new.DCTOutbit = 0 ;
    sim_new.ATAN1bit = 0 ;
    sim_new.ATAN2bit =0 ;
    sim_new.CFObit =0;
    sim_new.CSInbit = 0;
    sim_new.CSSumOutbit =0 ;
    sim_new.CSMulOutbit = 0 ;
    sim_new.CSAppr =0 ;
    sim_new.CFOinbit = 0;
    sim_new.CFO1inbit =0 ;
    sim_new.CFOMulOutbit = 0;    
    sim_new.CFOSumOutbit = 0;
    sim_new.CFO1MulOutbit = 0;    
    sim_new.CFO1SumOutbit = 0;
    sim_new.FSInbit=0;
    sim_new.FSMulOutbit = 0 ;
    sim_new.FSSumOutbit = 0 ;
    sim_new.FSEst =0;
end

sim_new.DACLim = 10^(sim_new.DACClipping/20) * 1 * sim.dacgain ;%0.1098 ;
sim_new.ADCLim = 10^(sim_new.ADCClipping/20) * 0.0014   ;

%% Check parameters.
if ( fiber.Npol < params_new.Nstream   )
    error (['Fiber polarization ' num2str(fiber.Npol) ...
        'Number of stream' params_new.Nstream ]);
end
%% EDFA
% 
% edfa.N_ASE =0 ;
% txedfa.N_ASE =0 ;
% rxedfa.N_ASE =0 ;
   
%% Fiber

if ( fiber.Npol == 1 )
    sim_new.rx_power_split = 1 ;
else
    if ( params_new.RXstream == 2 )
        sim_new.rx_power_split = ...
            [ cos(fiber.power_split2 *3.14),    sin(fiber.power_split2 *3.14); ...
             -sin(fiber.power_split2 *3.14),    cos(fiber.power_split2 *3.14);];
    else
        sim_new.rx_power_split = ...
            [ sqrt(fiber.power_split2),    sqrt(1-fiber.power_split2);];
    end
    if (  params_new.Nstream == 1) 
            sim_new.tx_power_split = [ sqrt(fiber.power_split1); sqrt(1-fiber.power_split1);];
    else
            sim_new.tx_power_split  = [ sqrt(fiber.power_split1),    sqrt(1-fiber.power_split1);  ...
                           sqrt(1-fiber.power_split1)  sqrt(fiber.power_split1); ];
    end
end

fiber_new.DeltaT = params_new.SampleTime / sim_new.oversample ;  %
if ( sim_new.cfotype ==5 || sim_new.cfotype == 8  )
    params_new.STF = zeros(1,params_new.NFFT);
    params_new.STF(sim.tone) = 1 +1j ;
    
end 
 if ( params_new.NOFDE == 0 || sim_new.precomp_en == 1 || sim_new.FiberLength == 0  )
     sim_new.en_OFDE =0;
 end

% if ( sim_new.multi_level == 1 )
%     sim_new.ofde =1;
% end
sim_new.span = sim_new.FiberLength/ edfa_new.length;

sim_new.fiber = fiber_new;
sim_new.rxedfa = rxedfa_new;
sim_new.edfa = edfa_new;
sim_new.lolaser = lolaser_new;
sim_new.PD = PD;
[sim_new.Launchpower, sim_new.LP_dB]=   GetLaunchPwr( laser, sim,  MZmod,  txedfa );
% sim.en_disp_env=0;
%% Simulation summary
if ( sim.en_disp_env )
    disp2( logfile,['Fixed ', num2str( sim_new.fixed_sim)]);
    disp2( logfile,['ADC, Mul, Tan in/out', ...
        num2str(sim_new.ADCbit),', ', ...
        num2str(sim_new.MulOutbit),', ', ...
        num2str(sim_new.ATANINbit), ...
        ', ', num2str(sim_new.ATANbit)]);

    disp2( logfile,['No Noise ', num2str(sim_new.nonoise)]);
    disp2( logfile,['SNR1 ', num2str(sim_new.SNR(1)), ' ']);
    disp2( logfile,['backtoback ', num2str(sim_new.backtoback)]);
    disp2( logfile,['FiberLength(km) ', num2str(sim_new.FiberLength/km)]);
    disp2( logfile,['Linewidth(kHz) ', num2str(laser_new.linewidth/kHz)]);
    disp2( logfile,['SFO(ppm) ', num2str(sim_new.txfreqoff/ppm)]);
    disp2( logfile,['CFO(MHz) ', num2str(laser_new.freqoff/MHz)]);
    disp2( logfile,['CFO(norm) ', num2str(laser_new.freqoff*2*pi*params_new.SampleTime)]);
    disp2( logfile,['Number of symbols per packet ', num2str(params_new.NSymbol)]);
    disp2( logfile,['Number of simulation per each point ', num2str(sim_new.MAXSIM)]);
    disp2( logfile,['Sampling frequency ', num2str(1/params_new.SampleTime /GHz),' GHz']); 
    % disp2( logfile,['TX Laser power ', num2str(10*log10( launch_power/mW)   ),' dBm']);     
    % disp2( logfile,['TX Gain ', num2str(10*log10(laser.launch_power/mW)   ),' dBm']);       
    disp2( logfile,['Modulation ', num2str( 2^params_new.Nbpsc ), 'QAM ']);    
    %The definitiona of raw data rate and norminal data rate are in 
    % S. L. Jansen, I. Morita, T. C. Schenk, N. Takeda, and H. Tanaka, 
    % "Coherent optical 25.8-Gb/s OFDM transmission over 4160-km SSMF," 
    % Journal of Lightwave Technology, vol. 26, pp. 6-15, 2008
    disp2( logfile,['Raw Datarate ', num2str( datarate / 10^9  ), ' Gbps ']);    
    disp2( logfile,['Norminal Datarate ', num2str( normdatarate / 10^9  ), ' Gbps ']);
    disp2( logfile,['FFT size ', num2str( params_new.NFFT ), ' ', ' CP cnt', num2str(params_new.NFFT * params_new.CPratio)]);
    disp2( logfile,['syncpoint ', num2str(sim_new.syncpoint ), ' ']);
    disp2( logfile,['Precomp enable ', num2str(  sim_new.precomp_en ), '. subband ', num2str(sim_new.subband)]);
    disp2( logfile,['CPE enable ', num2str(  sim_new.enCPEcomp )]);
    disp2( logfile,['CFO type ', num2str(  sim_new.cfotype)] ); 
    disp2( logfile,['Symbol sync search ', num2str(  sim_new.en_find_sync)] );
    disp2( logfile,['CS sync search ', num2str(  sim_new.en_find_cs)] );
    disp2( logfile,['OFDE size ', num2str( params_new.NOFDE )]);    
    disp2(logfile,datestr(now,'HH:MM /mm/dd/yy'))


end
